class EvenMoreFieldsInUser < ActiveRecord::Migration
  def change
    add_column :users, :about, :text
    add_column :users, :feedback, :text
    add_column :users, :role, :string
    add_column :users, :group, :integer
    add_column :projects, :city, :string
    add_column :projects, :video_url, :string
    add_column :projects, :details, :text
    add_column :users, :twitter, :string
    add_column :users, :linkedin, :string
    add_column :users, :blog, :string
    add_column :users, :receive_notifications, :boolean
  end

end
