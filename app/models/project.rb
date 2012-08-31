class Project < ActiveRecord::Base

  @@default_avatar_filename = 'default_project_logo.png'.freeze
  def self.default_avatar_filename; @@default_avatar_filename; end

  belongs_to :contest
  has_many :project_docs, :dependent => :destroy
  has_one :user, :dependent => :destroy
  validates_presence_of :name, :status
  validates_uniqueness_of :name
  validates_length_of :synopsys, :in => 0..141, :message => I18n::translate('common.too_long')
  validates_presence_of :synopsys, :details, :team, :business_model, :market, :competitors, :advantages, :technology, :finance, :current_stage, :if => :allow_validation
  #resizes to 700 pixes in width only if original image width is more than 700 px
  has_attached_file :avatar, :styles => {:medium => "700>", :thumb => "100x75#" }, :default_url => Project.default_avatar_filename
  validates_attachment_size :avatar, :less_than=>1.megabyte, :message => I18n::translate('common.too_large_attachment', :max => 1.megabyte)
  validates_attachment_content_type :avatar, :content_type=>['image/jpeg', 'image/png', 'image/gif', 'image/x-png', 'image/pjpeg']
  acts_as_commentable
  has_many :comments, {:foreign_key => 'commentable_id', :conditions => {:commentable_type => 'Project'}, :dependent => :destroy}

  attr_accessor :remove_avatar, :skip_validation
  attr_protected :status, :skip_validation
  before_create :set_contest
  before_save :check_values
  accepts_nested_attributes_for :project_docs, :allow_destroy => true, :reject_if => proc { |attributes| attributes['description'].blank? and attributes['doc'].blank?}

  @@status_draft        = 'DRAFT'
  @@status_added        = 'ADDED'
  @@status_disabled     = 'DISABLED'
  @@status_published    = 'PUBLISHED'
  @@status_selected     = 'SELECTED'
  @@status_short_listed = 'SHORT_LISTED'
  @@status_rejected     = 'REJECTED'
  @@status_resubmitted  = 'RESUBMITTED'

  def self.status_draft       ; @@status_draft       ; end
  def self.status_added       ; @@status_added       ; end
  def self.status_disabled    ; @@status_disabled    ; end
  def self.status_published   ; @@status_published   ; end
  def self.status_selected    ; @@status_selected    ; end
  def self.status_short_listed; @@status_short_listed; end
  def self.status_rejected    ; @@status_rejected    ; end
  def self.status_resubmitted ; @@status_resubmitted ; end

  def is_draft?       ; @@status_draft        == status;  end
  def is_added?       ; @@status_added        == status;  end
  def is_disabled?    ; @@status_disabled     == status;  end
  def is_published?   ; @@status_published    == status;  end
  def is_selected?    ; @@status_selected     == status;  end
  def is_short_listed?; @@status_short_listed == status;  end
  def is_rejected?    ; @@status_rejected     == status;  end
  def is_resubmitted? ; @@status_resubmitted  == status;  end

  def is_public?      ; [@@status_published, @@status_selected, @@status_short_listed].include? status;  end

  def is_waiting_for_moderation?; [@@status_added, @@status_resubmitted].include? status; end

  @@change_status_rules = {
    @@status_draft        => [@@status_added, @@status_disabled, @@status_rejected, @@status_published, @@status_selected, @@status_short_listed],
    @@status_added        => [@@status_draft, @@status_disabled, @@status_rejected, @@status_published, @@status_selected, @@status_short_listed],
    @@status_disabled     => [@@status_draft, @@status_published, @@status_selected, @@status_short_listed, @@status_rejected],
    @@status_published    => [@@status_draft, @@status_disabled, @@status_rejected, @@status_selected, @@status_short_listed],
    @@status_selected     => [@@status_draft, @@status_disabled, @@status_rejected, @@status_published, @@status_short_listed],
    @@status_short_listed => [@@status_draft, @@status_disabled, @@status_rejected, @@status_published, @@status_selected],
    @@status_rejected     => [@@status_draft, @@status_disabled, @@status_published, @@status_selected, @@status_short_listed],
    @@status_resubmitted  => [@@status_draft, @@status_disabled, @@status_rejected, @@status_published, @@status_selected, @@status_short_listed]
  }

  scope :public_scope, where(:status => [@@status_published, @@status_selected, @@status_short_listed])

  def self.change_status_rules
    @@change_status_rules
  end

  def self.all_statuses
    [
      @@status_draft       ,
      @@status_added       ,
      @@status_disabled    ,
      @@status_published   ,
      @@status_selected    ,
      @@status_short_listed,
      @@status_rejected    ,
      @@status_resubmitted
    ]
  end

  def allow_validation
    !(is_draft? or is_rejected? or skip_validation)
  end

  def public_fields
    [:name, :avatar, :avatar_file_name, :synopsys, :city, :url, :video_url]
  end

def completeness
    normal_fields = [:avatar_file_name, :url, :synopsys, :market, :competitors, :advantages, :technology, :finance, :current_stage, :team, :business_model, :city, :details]
    bonus_fields = [:video_url]
    completed, bonus = 0, 0

    # check normal fields
    normal_fields.each do |field|
      completed += 1 if self.send(field).length > 0 if self.send(field).present?
    end
    # check bonus fields
    bonus_fields.each do |field|
      bonus += 1 if self.send(field).length > 0 if self.send(field).present?
    end

    return normal_fields.length, completed, bonus
  end

  private

  def set_contest
    self.contest = Contest.order('id desc').first
  end

  def check_values
    avatar.destroy if remove_avatar == '1'
  end

end