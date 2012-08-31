class JoinFirstnameAndLastnameInUser < ActiveRecord::Migration
  def up
    rename_column :users, :lastname, :name
    remove_column :users, :firstname
  end

  def down
    rename_column :users, :name, :lastname
    add_column :users, :firstname, :string
  end
end
