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

ActiveRecord::Schema.define(:version => 20111212134234) do

  create_table "___restaurants", :force => true do |t|
    t.string   "name"
    t.integer  "network_id",                       :null => false
    t.string   "city"
    t.string   "address"
    t.string   "time"
    t.string   "phone"
    t.string   "web"
    t.text     "description"
    t.string   "breakfast"
    t.string   "businesslunch"
    t.string   "photo"
    t.float    "lon"
    t.float    "lat"
    t.integer  "votes",         :default => 0
    t.integer  "rating",        :default => 0
    t.string   "wifi",          :default => "0"
    t.boolean  "chillum",       :default => false
    t.boolean  "terrace",       :default => false
    t.boolean  "cc",            :default => false
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "children"
    t.string   "banquet"
    t.string   "reservation"
    t.string   "delivery"
    t.string   "takeaway"
    t.string   "service"
    t.string   "good_for"
    t.string   "alcohol"
    t.string   "noise"
    t.string   "tv"
    t.string   "disabled"
    t.string   "music"
    t.string   "parking"
    t.string   "menu_url"
    t.string   "bill"
    t.string   "sun"
    t.string   "mon"
    t.string   "tue"
    t.string   "wed"
    t.string   "thu"
    t.string   "fri"
    t.string   "sat"
  end

  add_index "___restaurants", ["address"], :name => "index_restaurants_on_address"
  add_index "___restaurants", ["cc"], :name => "index_restaurants_on_cc"
  add_index "___restaurants", ["chillum"], :name => "index_restaurants_on_chillum"
  add_index "___restaurants", ["city"], :name => "index_restaurants_on_city"
  add_index "___restaurants", ["id"], :name => "index_restaurants_on_id"
  add_index "___restaurants", ["name"], :name => "index_restaurants_on_name"
  add_index "___restaurants", ["terrace"], :name => "index_restaurants_on_terrace"
  add_index "___restaurants", ["wifi"], :name => "index_restaurants_on_wifi"

  create_table "__restaurants", :force => true do |t|
    t.string   "name"
    t.integer  "network_id",                       :null => false
    t.string   "city"
    t.string   "address"
    t.string   "time"
    t.string   "phone"
    t.string   "web"
    t.text     "description"
    t.string   "breakfast"
    t.string   "businesslunch"
    t.string   "photo"
    t.float    "lon"
    t.float    "lat"
    t.integer  "votes",         :default => 0
    t.integer  "rating",        :default => 0
    t.string   "wifi",          :default => "0"
    t.boolean  "chillum",       :default => false
    t.boolean  "terrace",       :default => false
    t.boolean  "cc",            :default => false
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "children"
    t.string   "banquet"
    t.string   "reservation"
    t.string   "delivery"
    t.string   "takeaway"
    t.string   "service"
    t.string   "good_for"
    t.string   "alcohol"
    t.string   "noise"
    t.string   "tv"
    t.string   "disabled"
    t.string   "music"
    t.string   "parking"
    t.string   "menu_url"
    t.string   "bill"
    t.string   "sun"
    t.string   "mon"
    t.string   "tue"
    t.string   "wed"
    t.string   "thu"
    t.string   "fri"
    t.string   "sat"
  end

  add_index "__restaurants", ["address"], :name => "index_restaurants_on_address"
  add_index "__restaurants", ["cc"], :name => "index_restaurants_on_cc"
  add_index "__restaurants", ["chillum"], :name => "index_restaurants_on_chillum"
  add_index "__restaurants", ["city"], :name => "index_restaurants_on_city"
  add_index "__restaurants", ["id"], :name => "index_restaurants_on_id"
  add_index "__restaurants", ["name"], :name => "index_restaurants_on_name"
  add_index "__restaurants", ["terrace"], :name => "index_restaurants_on_terrace"
  add_index "__restaurants", ["wifi"], :name => "index_restaurants_on_wifi"

  create_table "admins", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "authentications", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "provider",   :null => false
    t.string   "uid",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "backup__restaurants", :force => true do |t|
    t.string   "name"
    t.float    "lon"
    t.float    "lat"
    t.string   "address"
    t.integer  "network_id",                       :null => false
    t.string   "city"
    t.string   "time"
    t.string   "phone"
    t.string   "web"
    t.text     "description"
    t.string   "breakfast"
    t.string   "businesslunch"
    t.string   "photo"
    t.integer  "votes",         :default => 0
    t.integer  "rating",        :default => 0
    t.string   "wifi",          :default => "0"
    t.boolean  "chillum",       :default => false
    t.boolean  "terrace",       :default => false
    t.boolean  "cc",            :default => false
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "children"
    t.string   "banquet"
    t.string   "reservation"
    t.string   "delivery"
    t.string   "takeaway"
    t.string   "service"
    t.string   "good_for"
    t.string   "alcohol"
    t.string   "noise"
    t.string   "tv"
    t.string   "disabled"
    t.string   "music"
    t.string   "parking"
    t.string   "menu_url"
    t.string   "bill"
    t.string   "sun"
    t.string   "mon"
    t.string   "tue"
    t.string   "wed"
    t.string   "thu"
    t.string   "fri"
    t.string   "sat"
  end

  add_index "backup__restaurants", ["address"], :name => "index_restaurants_on_address"
  add_index "backup__restaurants", ["cc"], :name => "index_restaurants_on_cc"
  add_index "backup__restaurants", ["chillum"], :name => "index_restaurants_on_chillum"
  add_index "backup__restaurants", ["city"], :name => "index_restaurants_on_city"
  add_index "backup__restaurants", ["id"], :name => "index_restaurants_on_id"
  add_index "backup__restaurants", ["name"], :name => "index_restaurants_on_name"
  add_index "backup__restaurants", ["terrace"], :name => "index_restaurants_on_terrace"
  add_index "backup__restaurants", ["wifi"], :name => "index_restaurants_on_wifi"

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "review_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cuisines", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cuisines", ["id"], :name => "index_cuisines_on_id"
  add_index "cuisines", ["name"], :name => "index_cuisines_on_name"

  create_table "dish_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dish_categories", ["name"], :name => "name"

  create_table "dish_extratypes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dish_extratypes", ["id"], :name => "index_dish_extratypes_on_id"
  add_index "dish_extratypes", ["name"], :name => "index_dish_extratypes_on_name"

  create_table "dish_subtypes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dish_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dish_types", ["name"], :name => "name"

  create_table "dishes", :force => true do |t|
    t.string   "name"
    t.string   "photo"
    t.integer  "price",                           :default => 0
    t.string   "currency"
    t.float    "rating",            :limit => 21, :default => 0.0
    t.integer  "votes",                           :default => 0
    t.text     "description"
    t.integer  "restaurant_id",                   :default => 0
    t.integer  "network_id",                      :default => 0
    t.integer  "dish_category_id",                                 :null => false
    t.integer  "dish_type_id",                                     :null => false
    t.integer  "dish_subtype_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dish_extratype_id"
  end

  add_index "dishes", ["dish_category_id"], :name => "dish_category_id"
  add_index "dishes", ["dish_type_id"], :name => "dish_type_id"
  add_index "dishes", ["id"], :name => "id"
  add_index "dishes", ["network_id"], :name => "network_id"
  add_index "dishes", ["photo"], :name => "index_dishes_on_photo"
  add_index "dishes", ["rating"], :name => "index_dishes_on_rating"
  add_index "dishes", ["restaurant_id"], :name => "restaurant_id"
  add_index "dishes", ["votes"], :name => "index_dishes_on_votes"

  create_table "friends", :id => false, :force => true do |t|
    t.integer  "user_id",     :limit => 8, :null => false
    t.integer  "friend_id",   :limit => 8, :null => false
    t.string   "friend_name"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friends", ["friend_id", "user_id"], :name => "index_friends_on_friend_id_and_user_id"
  add_index "friends", ["user_id", "friend_id"], :name => "index_friends_on_user_id_and_friend_id"

  create_table "images", :force => true do |t|
    t.string   "photo"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "review_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rating",     :limit => 21
    t.integer  "votes",                    :default => 0
    t.string   "photo"
  end

  add_index "networks", ["rating"], :name => "index_networks_on_rating"
  add_index "networks", ["votes"], :name => "index_networks_on_votes"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.integer  "like_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["comment_id"], :name => "index_notifications_on_comment_id"
  add_index "notifications", ["id"], :name => "index_notifications_on_id"
  add_index "notifications", ["like_id"], :name => "index_notifications_on_like_id"
  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.string   "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "restaurant_cuisines", :id => false, :force => true do |t|
    t.integer "restaurant_id"
    t.integer "cuisine_id"
  end

  add_index "restaurant_cuisines", ["cuisine_id", "restaurant_id"], :name => "index_restaurant_cuisines_on_cuisine_id_and_restaurant_id"
  add_index "restaurant_cuisines", ["restaurant_id", "cuisine_id"], :name => "index_restaurant_cuisines_on_restaurant_id_and_cuisine_id"

  create_table "restaurant_images", :force => true do |t|
    t.integer  "restaurant_id", :null => false
    t.string   "photo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "restaurant_stations", :id => false, :force => true do |t|
    t.integer  "restaurant_id", :null => false
    t.integer  "station_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "restaurant_types", :id => false, :force => true do |t|
    t.integer "restaurant_id"
    t.integer "type_id"
  end

  add_index "restaurant_types", ["restaurant_id", "type_id"], :name => "index_restaurant_types_on_restaurant_id_and_type_id"
  add_index "restaurant_types", ["type_id", "restaurant_id"], :name => "index_restaurant_types_on_type_id_and_restaurant_id"

  create_table "restaurants", :force => true do |t|
    t.string   "name"
    t.float    "lon"
    t.float    "lat"
    t.string   "address"
    t.integer  "network_id",                                     :null => false
    t.string   "city"
    t.string   "time"
    t.string   "phone"
    t.string   "web"
    t.text     "description"
    t.string   "breakfast"
    t.string   "businesslunch"
    t.string   "photo"
    t.integer  "votes",                       :default => 0
    t.float    "rating",        :limit => 21
    t.string   "wifi",                        :default => "0"
    t.boolean  "chillum",                     :default => false
    t.boolean  "terrace",                     :default => false
    t.boolean  "cc",                          :default => false
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "children"
    t.string   "banquet"
    t.string   "reservation"
    t.string   "delivery"
    t.string   "takeaway"
    t.string   "service"
    t.string   "good_for"
    t.string   "alcohol"
    t.string   "noise"
    t.string   "tv"
    t.string   "disabled"
    t.string   "music"
    t.string   "parking"
    t.string   "menu_url"
    t.string   "bill"
    t.string   "sun"
    t.string   "mon"
    t.string   "tue"
    t.string   "wed"
    t.string   "thu"
    t.string   "fri"
    t.string   "sat"
  end

  add_index "restaurants", ["address"], :name => "index_restaurants_on_address"
  add_index "restaurants", ["cc"], :name => "index_restaurants_on_cc"
  add_index "restaurants", ["chillum"], :name => "index_restaurants_on_chillum"
  add_index "restaurants", ["city"], :name => "index_restaurants_on_city"
  add_index "restaurants", ["id"], :name => "index_restaurants_on_id"
  add_index "restaurants", ["lat"], :name => "index_restaurants_on_lat"
  add_index "restaurants", ["lon"], :name => "index_restaurants_on_lon"
  add_index "restaurants", ["name"], :name => "index_restaurants_on_name"
  add_index "restaurants", ["network_id"], :name => "index_restaurants_on_network_id"
  add_index "restaurants", ["terrace"], :name => "index_restaurants_on_terrace"
  add_index "restaurants", ["wifi"], :name => "index_restaurants_on_wifi"

  create_table "reviews", :force => true do |t|
    t.string   "photo"
    t.float    "rating",         :default => 0.0
    t.text     "text"
    t.integer  "dish_id",                           :null => false
    t.integer  "user_id",                           :null => false
    t.integer  "restaurant_id",                     :null => false
    t.integer  "count_likes",    :default => 0
    t.integer  "count_comments", :default => 0
    t.boolean  "web",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "network_id",     :default => 0
  end

  add_index "reviews", ["count_likes"], :name => "index_reviews_on_count_likes"
  add_index "reviews", ["dish_id"], :name => "index_reviews_on_dish_id"
  add_index "reviews", ["id"], :name => "index_reviews_on_id"
  add_index "reviews", ["user_id"], :name => "index_reviews_on_user_id"

  create_table "stations", :force => true do |t|
    t.string   "name"
    t.float    "lat"
    t.float    "lon"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "types", ["id"], :name => "index_types_on_id"
  add_index "types", ["name"], :name => "index_types_on_name"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "photo"
    t.string   "name"
    t.integer  "facebook_id",                  :limit => 8
  end

  add_index "users", ["remember_me_token"], :name => "index_users_on_remember_me_token"

end
