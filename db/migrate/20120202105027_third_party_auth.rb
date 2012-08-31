class ThirdPartyAuth < ActiveRecord::Migration

  def up
    create_table "authentications", :force => true do |t|
      t.integer "user_id",  :null => true
      t.string  "uid",      :null => false
      t.string  "provider", :null => false
      t.string "image_url", :null => true
      t.string "profile_url", :null => true
    end

    execute("update users set password_digest = null where user_type = '#{User.type_lector}' or status = '#{User.status_invited}';")
    execute("update projects set status = '#{Project.status_draft}' where status = '#{Project.status_added}';")
  end

  def down

    drop_table "authentications"


  end
end
