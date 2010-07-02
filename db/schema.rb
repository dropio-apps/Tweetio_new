# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100614082321) do

  create_table "comments", :force => true do |t|
    t.integer  "users_id"
    t.integer  "upload_file_id"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contents", :force => true do |t|
    t.string "content_type"
    t.string "content_name"
  end

  create_table "upload_files", :force => true do |t|
    t.integer  "user_id"
    t.integer  "content_id"
    t.text     "title"
    t.text     "name"
    t.text     "description"
    t.string   "original_file_name"
    t.string   "file_size"
    t.string   "height"
    t.string   "width"
    t.string   "status"
    t.string   "converted_file_name"
    t.text     "thumbnail"
    t.text     "large_thumb"
    t.string   "drop_name"
    t.text     "hidden_url"
    t.text     "url"
    t.integer  "view_count"
    t.text     "embed_code"
    t.integer  "upload_player_type"
    t.string   "encrypt_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "media_name"
    t.string   "file_field_file_name"
  end

  create_table "users", :force => true do |t|
    t.string   "twitter_id"
    t.string   "login"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "location"
    t.string   "description"
    t.string   "profile_image_url"
    t.binary   "drop_name",                    :limit => 255
    t.string   "url"
    t.boolean  "protected"
    t.string   "profile_background_color"
    t.string   "profile_sidebar_fill_color"
    t.string   "profile_link_color"
    t.string   "profile_sidebar_border_color"
    t.string   "profile_text_color"
    t.string   "profile_background_image_url"
    t.boolean  "profile_background_tile"
    t.integer  "friends_count"
    t.integer  "statuses_count"
    t.integer  "followers_count"
    t.integer  "favourites_count"
    t.integer  "utc_offset"
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
