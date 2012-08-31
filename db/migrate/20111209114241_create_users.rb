class CreateUsers < ActiveRecord::Migration

  def change
    create_table :users do |t|
      t.integer :project_id,  :null => true
      t.string :firstname,    :null => true
      t.string :lastname ,    :null => true
      t.string :email    ,    :null => true
      t.string :status   ,    :null => false
      t.string :user_type,    :null => false
      t.string :password_digest,      :null => true
      t.string :reset_token,      :null => true
      t.string :invite_token,     :null => true
      t.datetime :last_login_date,  :null => true
      t.boolean :is_admin, :default => false
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
    create_table :projects do |t|
      t.integer  :contest_id, :null => false
      t.string   :name,    :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :created_by
      t.integer  :updated_by
    end

    create_table :contest do |t|
      t.string   :name,    :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end


end
