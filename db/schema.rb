# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120212224000) do

  create_table "authentications", :force => true do |t|
    t.integer "user_id"
    t.string  "uid",         :null => false
    t.string  "provider",    :null => false
    t.string  "image_url"
    t.string  "profile_url"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",   :default => 0
    t.string   "commentable_type", :default => ""
    t.string   "title",            :default => ""
    t.text     "body"
    t.string   "subject",          :default => ""
    t.integer  "user_id",          :default => 0,  :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contests", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "deadline",   :null => false
    t.string   "name_en"
    t.string   "name_es"
  end

  create_table "project_docs", :force => true do |t|
    t.integer  "project_id"
    t.string   "description"
    t.string   "doc_file_name"
    t.string   "doc_content_type"
    t.integer  "doc_file_size"
    t.datetime "doc_updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "projects", :force => true do |t|
    t.integer  "contest_id",          :null => false
    t.string   "name",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "url"
    t.text     "synopsys"
    t.text     "market"
    t.text     "competitors"
    t.text     "advantages"
    t.text     "technology"
    t.text     "finance"
    t.text     "current_stage"
    t.text     "team"
    t.text     "business_model"
    t.string   "status"
    t.string   "city"
    t.string   "video_url"
    t.text     "details"
  end

  create_table "users", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "email"
    t.string   "status",                                                                              :null => false
    t.string   "user_type",                                                                           :null => false
    t.string   "password_digest"
    t.string   "reset_token"
    t.string   "invite_token"
    t.datetime "last_login_date"
    t.boolean  "is_admin",                                                         :default => false, :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "skype"
    t.text     "about"
    t.text     "feedback"
    t.string   "role"
    t.integer  "group",                 :limit => 1,                               :default => 0,     :null => false
    t.string   "twitter"
    t.string   "linkedin"
    t.string   "blog"
    t.boolean  "receive_notifications"
    t.decimal  "group_order_number",                 :precision => 6, :scale => 2
    t.text     "about_en"
    t.text     "about_es"
    t.string   "locale",                :limit => 2,                               :default => "ru",  :null => false
    t.string   "name_en"
    t.string   "name_es"
    t.string   "role_en"
    t.string   "role_es"
  end

end
