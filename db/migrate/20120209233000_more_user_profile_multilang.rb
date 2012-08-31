class MoreUserProfileMultilang < ActiveRecord::Migration
  def up
    add_column :users, :name_en, :string
    add_column :users, :name_es, :string
    add_column :users, :role_en, :string
    add_column :users, :role_es, :string
  end

  def down
    remove_column :users, :name_en
    remove_column :users, :name_es
    remove_column :users, :role_en
    remove_column :users, :role_es
  end
end
