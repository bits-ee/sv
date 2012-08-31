class CreateProjectDocs < ActiveRecord::Migration
  def self.up
    change_table :projects do |t|
      t.has_attached_file :avatar
    end
    create_table :project_docs do |t|
      t.integer :project_id
      t.string :description
      t.string :doc_file_name
      t.string :doc_content_type
      t.integer :doc_file_size
      t.datetime :doc_updated_at
      t.integer :created_by
      t.integer :updated_by
    end
  end

  def self.down
    drop_attached_file :projects, :avatar
    drop_table :project_docs
  end
end
