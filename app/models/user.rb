class User < ActiveRecord::Base

  class AdminValidator < ActiveModel::Validator
    def validate(record)
      (record.errors[:is_admin] << 'oops.. this user cant be an admin.') and return if !record.is_priority? and record.changed_attributes.include?("is_admin")
      (record.errors[:group] << 'oops.. this user cant have a group.') and return if !(record.is_priority? or record.is_lector?) and  record.changed_attributes.include?("group")
      self_id = record.id
      if record.is_priority? and record.changed_attributes.include?("is_admin") and !record.is_admin? and User.find_all_by_is_admin(true).reject{|u| u.id == self_id}.size == 0
        record.errors[:is_admin] << I18n::translate('user.last_admin')
      end
    end
  end

  class CustomPasswordDigestValidator < ActiveModel::Validator
    def validate(record)
      errors = record.errors
      errors.each do |attribute, error|
        # we ignore password digest requirement, if:
          # user is lector
          # or user is just invited
          # or existed user authorized through social network
          # or new user authorized through social network
        if attribute == :password_digest && (record.is_lector? || record.is_invited? || (record.persisted? && record.authentication.present?) || Authentication.find_by_id_and_user_id(record.auth_id, nil).present? || errors.keys.include?(:password))
          errors.messages[attribute].each do |msg|
            errors.messages[attribute].delete_at(errors.messages[attribute].index(msg))
          end
          errors.messages.delete(attribute) if errors.messages[attribute].empty?
        end
      end
    end
  end

  has_one :authentication, :dependent => :destroy
  belongs_to :project
  has_secure_password

  has_attached_file :avatar, :styles => { :medium => "400>", :thumb => "94x94" }, :default_url => :default_url_by_user_type
  validates_attachment_size :avatar, :less_than=>1.megabyte, :message => I18n::translate('common.too_large_attachment', :max => 1)
  validates_attachment_content_type :avatar, :content_type=>['image/jpeg', 'image/png', 'image/gif', 'image/x-png', 'image/pjpeg']
  validates_with AdminValidator, :on => :update
  attr_accessor :reset_password, :current_password, :remove_avatar, :auth_id
  attr_accessible :email, :name, :name_en, :name_es, :project_id, :password, :password_confirmation, :created_by, :updated_by, :last_login_date, :is_admin, :avatar, :remove_avatar, :skype, :about, :about_en, :about_es, :feedback, :role, :role_en, :role_es, :group, :twitter, :blog, :linkedin, :receive_notifications, :group_order_number, :locale

  validates_presence_of :status, :user_type

  #we need to check password availability when user registers itself and his project
  validates_presence_of :password, :on => :create, :if => Proc.new { |user|
    user.status == @@status_active and user.user_type != @@type_lector and Authentication.find_by_id_and_user_id(user.auth_id, nil).blank?
  }
  validates_with CustomPasswordDigestValidator
  #or on update (change or reset forgotten password)
  validates_presence_of :password, :on => :update, :if => Proc.new { |user|

    # in case of password reset
    result = (user.user_type != @@type_lector and user.status == @@status_active and user.reset_token.present? and user.reset_token == user.reset_password)
    return true if result

    # in case of password change
    result = (user.user_type != @@type_lector and user.status != @@status_invited and !user.current_password.nil?)
    if result
      if User.find(user.id).authenticate(user.current_password)
        #current password matches, should validate presence of (new) password
        return true
      else
        #current password doesn't match.
        user.errors.add(:current_password, I18n::translate('common.doesnt_match')) and return false
      end
    end

    # if user accepts invitation
    result = (([@@type_regular, @@type_priority].include? user.user_type) and user.status == @@status_active and user.invite_token.present?)
    if result
      user.invite_token = nil
      return true
    end

    #user tries to change password not within two above cases.
    raise I18n::translate('user.access_denied') if !result and user.changed_attributes.include? 'password_digest'

    #this is not a case of password changing, we dont need to validate it.
    return false
  }

  validates_presence_of :email, :if => :requires_email
  validates_uniqueness_of :email, :if => :requires_email, :allow_blank => true, :allow_nil => false#, :message => I18n::translate('user.email_already_used')
  validates_presence_of :name, :if => :requires_name
  validates_uniqueness_of :name, :if => :requires_name
  validates_format_of :email, :if => :requires_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_numericality_of :group_order_number, :allow_nil => true, :greater_than => 0, :only_integer => false, :less_than => 10000

  before_create :generate_invite_token, :if => Proc.new{ |user| user.status == @@status_invited }
  before_save :check_values

  @@status_invited = 'INVITED'
  @@status_disabled = 'DISABLED'
  @@status_active = 'ACTIVE'

  def self.status_invited   ; @@status_invited  ; end
  def self.status_active    ; @@status_active   ; end
  def self.status_disabled  ; @@status_disabled ; end

  def is_invited?   ; @@status_invited == status; end
  def is_active?    ; @@status_active  == status; end
  def is_disabled?  ; @@status_disabled== status; end

  @@type_regular  = 'REGULAR'
  @@type_priority = 'PRIORITY'
  @@type_lector   = 'LECTOR'
  @@type_mentor   = 'MENTOR'
  @@type_guest    = 'GUEST'
  @@type_alumni   = 'ALUMNI'

  def self.type_regular   ; @@type_regular    ; end
  def self.type_priority  ; @@type_priority   ; end
  def self.type_lector    ; @@type_lector     ; end
  def self.type_mentor    ; @@type_mentor     ; end
  def self.type_guest     ; @@type_guest      ; end
  def self.type_alumni    ; @@type_alumni     ; end

  def is_regular?   ; user_type == @@type_regular ; end
  def is_priority?  ; user_type == @@type_priority; end
  def is_lector?    ; user_type == @@type_lector  ; end
  def is_mentor?    ; user_type == @@type_mentor  ; end
  def is_guest?     ; user_type == @@type_guest   ; end
  def is_alumni?    ; user_type == @@type_alumni  ; end
  def is_admin?     ; is_admin and user_type == @@type_priority; end

  def self.user_types ; [@@type_priority, @@type_lector, @@type_regular, @@type_mentor, @@type_guest, @@type_alumni]; end

  def full_name
    name.present? ? name : email
  end
  alias fullname full_name

  alias :new_password :password

  def self.find_invited_user_and_project(email, invite_token)
    user = self.where(:email => email.strip, :status => status_invited, :invite_token => invite_token.strip).includes(:project).first
    return user, user ? user.project : nil
  end

  def generate_invite_token
    begin
      token = SecureRandom.hex(8).upcase
    end while User.where(:invite_token => token).size != 0
    self.invite_token = token
  end

  def generate_reset_token
    begin
      token = SecureRandom.hex(8).upcase
    end while User.where(:reset_token => token).size != 0
    self.reset_token = token
  end


  def can_comment?
    is_priority?
  end

  def is_owner_of_public_project? project
    is_regular? and project.present? and project.is_public? and self.project_id == project.id
  end

  def can_see_all_of(project_id)
    is_priority? or project_id == self.project_id
  end

  def requires_email
    !is_lector?
  end

  def requires_name
    is_lector?
  end

  def self.admins_to_notify
    User.find_all_by_is_admin_and_receive_notifications(true, true)
  end
  
  def completeness
    normal_fields = [:avatar_file_name, :skype, :twitter, :linkedin, :blog, :about, :role]
    bonus_fields = []
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

  def default_url_by_user_type
    "user_#{user_type.downcase}.png"
  end

  def public_fields
    [:name, :name_es, :name_en, :avatar, :avatar_file_name, :about, :about_es, :about_en, :role, :role_es, :role_en]
  end

  private

  def check_values
    avatar.destroy if remove_avatar == '1'
  end
end
