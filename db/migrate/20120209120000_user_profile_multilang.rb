class UserProfileMultilang < ActiveRecord::Migration
  def up
    add_column :users, :about_en, :text
    add_column :users, :about_es, :text
    add_column :users, :locale, :string, :null => false, :limit => 2, :default => 'ru'
  end

  def down
    remove_column :users, :about_en
    remove_column :users, :about_es
    remove_column :users, :locale
  end
end
