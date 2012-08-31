class Contest < ActiveRecord::Base
  has_many :projects
  validates_presence_of :name, :deadline
end
