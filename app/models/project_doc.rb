class ProjectDoc < ActiveRecord::Base
  has_attached_file :doc
  belongs_to :project
  validates_attachment_size :doc, :less_than=> 5.megabytes, :message => I18n::translate('user.too_large_attachment', :max => 5.megabytes)
  validates_attachment_presence :doc

end
