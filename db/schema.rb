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

ActiveRecord::Schema.define(:version => 20120525134650) do

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

  create_table "apn_devices", :force => true do |t|
    t.string   "token",              :default => "",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_registered_at"
    t.integer  "user_id",            :default => 0
    t.boolean  "active",             :default => true
  end

  add_index "apn_devices", ["token"], :name => "index_apn_devices_on_token", :unique => true

  create_table "apn_notifications", :force => true do |t|
    t.integer  "device_id",                            :null => false
    t.datetime "sent_at"
    t.integer  "errors_nb",         :default => 0
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.text     "custom_properties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "mailed_at"
    t.integer  "user_id_to",                           :null => false
    t.integer  "user_id_from",                         :null => false
    t.boolean  "read",              :default => false
    t.string   "notification_type"
    t.integer  "review_id",         :default => 0
    t.boolean  "push_allow",        :default => true
    t.boolean  "email_allow",       :default => true
  end

  add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "provider",   :null => false
    t.string   "uid",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "review_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read"
  end

  create_table "cuisines", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cuisines", ["id"], :name => "index_cuisines_on_id"
  add_index "cuisines", ["name"], :name => "index_cuisines_on_name"

  create_table "deliveries", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.string   "address"
    t.string   "time"
    t.string   "phone"
    t.string   "web"
    t.text     "description"
    t.string   "photo"
    t.float    "lon"
    t.float    "lat"
    t.integer  "votes",       :default => 0
    t.integer  "rating",      :default => 0
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_eng"
    t.integer  "top_user_id", :default => 0
    t.string   "fsq_id"
    t.integer  "bill",        :default => 0
  end

  add_index "deliveries", ["address"], :name => "index_deliveries_on_address"
  add_index "deliveries", ["city"], :name => "index_deliveries_on_city"
  add_index "deliveries", ["id"], :name => "index_deliveries_on_id"
  add_index "deliveries", ["name"], :name => "index_deliveries_on_name"

  create_table "delivery_tags", :force => true do |t|
    t.integer  "tag_id",      :null => false
    t.integer  "delivery_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delivery_tags", ["delivery_id"], :name => "index_delivery_tags_on_delivery_id"
  add_index "delivery_tags", ["tag_id"], :name => "index_delivery_tags_on_tag_id"

  create_table "dish_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_eng"
  end

  add_index "dish_categories", ["name"], :name => "name"

  create_table "dish_category_orders", :force => true do |t|
    t.integer  "restaurant_id",                   :null => false
    t.integer  "network_id",                      :null => false
    t.integer  "dish_category_id",                :null => false
    t.integer  "order",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dish_category_orders", ["dish_category_id"], :name => "index_dish_category_orders_on_dish_category_id"
  add_index "dish_category_orders", ["id"], :name => "index_dish_category_orders_on_id"
  add_index "dish_category_orders", ["network_id"], :name => "index_dish_category_orders_on_network_id"
  add_index "dish_category_orders", ["restaurant_id"], :name => "index_dish_category_orders_on_restaurant_id"

  create_table "dish_comments", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "dish_id",    :null => false
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dish_deliveries", :force => true do |t|
    t.string   "name"
    t.string   "photo"
    t.integer  "price",             :default => 0
    t.string   "currency"
    t.integer  "rating",            :default => 0
    t.integer  "votes",             :default => 0
    t.text     "description"
    t.integer  "delivery_id",       :default => 0
    t.integer  "dish_category_id",                 :null => false
    t.integer  "dish_type_id",                     :null => false
    t.integer  "dish_subtype_id",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "top_user_id",       :default => 0
    t.integer  "dish_extratype_id", :default => 0
    t.integer  "created_by_user",   :default => 0
    t.integer  "count_comments",    :default => 0
    t.integer  "count_likes",       :default => 0
    t.integer  "no_rate_order",     :default => 0
  end

  create_table "dish_delivery_category_orders", :force => true do |t|
    t.integer  "delivery_id",                     :null => false
    t.integer  "dish_category_id",                :null => false
    t.integer  "order",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dish_delivery_category_orders", ["delivery_id"], :name => "index_dish_delivery_category_orders_on_delivery_id"
  add_index "dish_delivery_category_orders", ["dish_category_id"], :name => "index_dish_delivery_category_orders_on_dish_category_id"
  add_index "dish_delivery_category_orders", ["id"], :name => "index_dish_delivery_category_orders_on_id"

  create_table "dish_delivery_comments", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "dish_id",    :null => false
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dish_delivery_likes", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "dish_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dish_delivery_tags", :force => true do |t|
    t.integer  "tag_id",           :null => false
    t.integer  "dish_delivery_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dish_delivery_tags", ["dish_delivery_id"], :name => "index_dish_delivery_tags_on_dish_delivery_id"
  add_index "dish_delivery_tags", ["id"], :name => "index_dish_delivery_tags_on_id"
  add_index "dish_delivery_tags", ["tag_id"], :name => "index_dish_delivery_tags_on_tag_id"

  create_table "dish_extratypes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dish_extratypes", ["id"], :name => "index_dish_extratypes_on_id"
  add_index "dish_extratypes", ["name"], :name => "index_dish_extratypes_on_name"

  create_table "dish_likes", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "dish_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dish_subtypes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dish_type_id", :null => false
    t.string   "name_eng"
  end

  create_table "dish_tags", :force => true do |t|
    t.integer  "tag_id",     :null => false
    t.integer  "dish_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dish_tags", ["dish_id"], :name => "index_dish_tags_on_dish_id"
  add_index "dish_tags", ["tag_id"], :name => "index_dish_tags_on_tag_id"

  create_table "dish_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",      :default => 0
    t.string   "name_eng"
    t.string   "photo"
  end

  add_index "dish_types", ["name"], :name => "name"

  create_table "dishes", :force => true do |t|
    t.integer  "network_id",                                                           :default => 0
    t.string   "name"
    t.string   "photo"
    t.decimal  "price",                                 :precision => 10, :scale => 0, :default => 0
    t.string   "currency"
    t.float    "rating",                  :limit => 21,                                :default => 0.0
    t.integer  "votes",                                                                :default => 0
    t.text     "description"
    t.integer  "dish_category_id"
    t.integer  "dish_type_id"
    t.integer  "dish_subtype_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dish_extratype_id"
    t.integer  "created_by_user",         :limit => 1,                                 :default => 0,   :null => false
    t.integer  "network_rating"
    t.integer  "network_votes"
    t.integer  "network_fsq_users_count"
    t.integer  "count_comments",                                                       :default => 0
    t.integer  "count_likes",                                                          :default => 0
    t.integer  "top_user_id",                                                          :default => 0
    t.integer  "fsq_checkins_count",                                                   :default => 0
    t.integer  "no_rate_order",                                                        :default => 0
  end

  add_index "dishes", ["dish_category_id"], :name => "dish_category_id"
  add_index "dishes", ["dish_type_id"], :name => "dish_type_id"
  add_index "dishes", ["id"], :name => "id"
  add_index "dishes", ["name"], :name => "name"
  add_index "dishes", ["network_fsq_users_count"], :name => "index_dishes_on_network_fsq_users_count"
  add_index "dishes", ["network_id"], :name => "network_id"
  add_index "dishes", ["network_rating"], :name => "index_dishes_on_network_rating"
  add_index "dishes", ["network_votes"], :name => "index_dishes_on_network_votes"
  add_index "dishes", ["no_rate_order"], :name => "index_dishes_on_no_rate_order"
  add_index "dishes", ["photo"], :name => "index_dishes_on_photo"
  add_index "dishes", ["rating"], :name => "index_dishes_on_rating"
  add_index "dishes", ["votes"], :name => "index_dishes_on_votes"

  create_table "favourites", :force => true do |t|
    t.integer  "dish_id",          :default => 0
    t.integer  "restaurant_id",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "delivery_id",      :default => 0
    t.integer  "dish_delivery_id", :default => 0
    t.integer  "home_cook_id",     :default => 0
    t.integer  "network_id"
  end

  add_index "favourites", ["delivery_id"], :name => "index_favourites_on_delivery_id"
  add_index "favourites", ["dish_delivery_id"], :name => "index_favourites_on_dish_delivery_id"
  add_index "favourites", ["home_cook_id"], :name => "index_favourites_on_home_cook_id"

  create_table "followers", :force => true do |t|
    t.integer  "user_id",        :null => false
    t.integer  "follow_user_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read"
  end

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

  create_table "home_cook_tags", :force => true do |t|
    t.integer  "tag_id",       :null => false
    t.integer  "home_cook_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "home_cook_tags", ["home_cook_id"], :name => "index_home_cook_tags_on_home_cook_id"
  add_index "home_cook_tags", ["id"], :name => "index_home_cook_tags_on_id"
  add_index "home_cook_tags", ["tag_id"], :name => "index_home_cook_tags_on_tag_id"

  create_table "home_cooks", :force => true do |t|
    t.string   "name"
    t.string   "photo"
    t.integer  "rating",                                           :default => 0
    t.integer  "votes",                                            :default => 0
    t.text     "description"
    t.integer  "dish_type_id",                                                    :null => false
    t.integer  "dish_subtype_id"
    t.integer  "dish_extratype_id"
    t.integer  "created_by_user"
    t.integer  "count_comments",                                   :default => 0
    t.integer  "count_likes",                                      :default => 0
    t.integer  "top_user_id",                                      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",             :precision => 10, :scale => 0
  end

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
    t.boolean  "read"
  end

  add_index "likes", ["user_id", "review_id"], :name => "index_likes_on_user_id_and_review_id"

  create_table "location_tips", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mi_dishes", :id => false, :force => true do |t|
    t.integer  "id",               :null => false
    t.string   "category_id"
    t.string   "category_name"
    t.string   "restaurant_id"
    t.string   "category_picture"
    t.string   "description"
    t.integer  "mi_id",            :null => false
    t.string   "kilo_calories"
    t.string   "cousine"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "likes"
    t.string   "name"
    t.string   "pictures"
    t.string   "price"
    t.string   "restaurant_name",  :null => false
    t.string   "composition"
    t.string   "vegetarian"
    t.string   "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mi_dishes", ["mi_id"], :name => "mi_id"
  add_index "mi_dishes", ["name"], :name => "name"
  add_index "mi_dishes", ["restaurant_name"], :name => "restaurant_name"

  create_table "mi_restaurants", :force => true do |t|
    t.string   "mi_id"
    t.string   "name"
    t.integer  "our_network_id"
    t.integer  "network_id"
    t.string   "step",           :null => false
    t.string   "address"
    t.string   "description"
    t.string   "dishes"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "metro"
    t.string   "picture"
    t.string   "site"
    t.string   "telephone"
    t.string   "wifi"
    t.string   "worktime"
    t.string   "city",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rating",             :limit => 21, :default => 0.0
    t.integer  "votes",                            :default => 0
    t.string   "photo"
    t.integer  "fsq_users_count"
    t.integer  "fsq_checkins_count",               :default => 0
    t.string   "city"
  end

  add_index "networks", ["fsq_users_count"], :name => "index_networks_on_fsq_users_count"
  add_index "networks", ["id"], :name => "index_networks_on_id"
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

  create_table "parser_stats", :force => true do |t|
    t.string   "find_loc"
    t.string   "cflt"
    t.string   "url"
    t.boolean  "status",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "parser_stats", ["cflt"], :name => "index_parser_stats_on_cflt"
  add_index "parser_stats", ["find_loc"], :name => "index_parser_stats_on_find_loc"
  add_index "parser_stats", ["status"], :name => "index_parser_stats_on_status"

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

  create_table "restaurant_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "restaurant_tags", :force => true do |t|
    t.integer  "tag_id",        :null => false
    t.integer  "restaurant_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "restaurant_tags", ["restaurant_id"], :name => "index_restaurant_tags_on_restaurant_id"
  add_index "restaurant_tags", ["tag_id"], :name => "index_restaurant_tags_on_tag_id"

  create_table "restaurant_types", :id => false, :force => true do |t|
    t.integer "restaurant_id"
    t.integer "type_id"
  end

  add_index "restaurant_types", ["restaurant_id", "type_id"], :name => "index_restaurant_types_on_restaurant_id_and_type_id"
  add_index "restaurant_types", ["type_id", "restaurant_id"], :name => "index_restaurant_types_on_type_id_and_restaurant_id"

  create_table "restaurants", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.integer  "network_id",                                             :null => false
    t.float    "rating",                :limit => 21, :default => 0.0
    t.string   "name_eng"
    t.float    "lon"
    t.float    "lat"
    t.string   "fsq_lng"
    t.string   "fsq_lat"
    t.string   "address"
    t.string   "time"
    t.string   "phone"
    t.string   "web"
    t.text     "description"
    t.string   "breakfast",                           :default => "0"
    t.string   "businesslunch",                       :default => "0"
    t.string   "photo"
    t.integer  "votes",                               :default => 0
    t.string   "wifi",                                :default => "0"
    t.string   "chillum",                             :default => "0"
    t.string   "terrace",                             :default => "0"
    t.string   "cc",                                  :default => "0"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "good_for_kids",                       :default => "0"
    t.boolean  "banquet",                             :default => false
    t.string   "reservation",                         :default => "0"
    t.string   "delivery",                            :default => "0"
    t.boolean  "takeaway",                            :default => false
    t.boolean  "service",                             :default => false
    t.string   "alcohol",                             :default => "0"
    t.string   "noise",                               :default => "0"
    t.boolean  "tv",                                  :default => false
    t.string   "disabled",                            :default => "0"
    t.string   "music",                               :default => "0"
    t.string   "parking",                             :default => "0"
    t.string   "menu_url"
    t.string   "bill"
    t.string   "sun",                                 :default => ""
    t.string   "mon",                                 :default => ""
    t.string   "tue",                                 :default => ""
    t.string   "wed",                                 :default => ""
    t.string   "thu",                                 :default => ""
    t.string   "fri",                                 :default => ""
    t.string   "sat",                                 :default => ""
    t.integer  "fsq_checkins_count"
    t.integer  "fsq_tip_count"
    t.integer  "fsq_users_count"
    t.string   "fsq_name"
    t.string   "fsq_address"
    t.string   "fsq_id"
    t.string   "station"
    t.integer  "top_user_id",                         :default => 0
    t.string   "restaurant_categories",               :default => "0"
    t.boolean  "delivery_only"
    t.string   "attire",                              :default => "0"
    t.string   "transit",                             :default => "0"
    t.string   "caters",                              :default => "0"
    t.string   "ambience",                            :default => "0"
    t.boolean  "good_for_groups",                     :default => false
    t.string   "good_for_meal",                       :default => "0"
    t.string   "time_zone_offset"
  end

  add_index "restaurants", ["address"], :name => "index_restaurants_on_address"
  add_index "restaurants", ["cc"], :name => "index_restaurants_on_cc"
  add_index "restaurants", ["chillum"], :name => "index_restaurants_on_chillum"
  add_index "restaurants", ["city"], :name => "index_restaurants_on_city"
  add_index "restaurants", ["id"], :name => "index_restaurants_on_id"
  add_index "restaurants", ["lat"], :name => "index_restaurants_on_lat"
  add_index "restaurants", ["lon"], :name => "index_restaurants_on_lon"
  add_index "restaurants", ["name"], :name => "index_restaurants_on_name"
  add_index "restaurants", ["name_eng"], :name => "index_restaurants_on_name_eng"
  add_index "restaurants", ["network_id"], :name => "index_restaurants_on_network_id"
  add_index "restaurants", ["terrace"], :name => "index_restaurants_on_terrace"
  add_index "restaurants", ["wifi"], :name => "index_restaurants_on_wifi"

  create_table "reviews", :force => true do |t|
    t.string   "photo"
    t.float    "rating",            :default => 0.0
    t.text     "text"
    t.integer  "dish_id",                              :null => false
    t.integer  "user_id",                              :null => false
    t.integer  "restaurant_id"
    t.integer  "count_likes",       :default => 0
    t.integer  "count_comments",    :default => 0
    t.boolean  "web",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "network_id",        :default => 0
    t.string   "rtype"
    t.text     "friends"
    t.string   "facebook_share_id"
    t.float    "lat"
    t.float    "lng"
  end

  add_index "reviews", ["count_likes"], :name => "index_reviews_on_count_likes"
  add_index "reviews", ["dish_id"], :name => "index_reviews_on_dish_id"
  add_index "reviews", ["id"], :name => "index_reviews_on_id"
  add_index "reviews", ["user_id"], :name => "index_reviews_on_user_id"

  create_table "search_words", :force => true do |t|
    t.string   "name"
    t.integer  "count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.integer  "user_id",       :default => 0
    t.string   "session_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salt"
  end

  add_index "sessions", ["id"], :name => "index_sessions_on_id"
  add_index "sessions", ["user_id"], :name => "index_sessions_on_user_id"

  create_table "specials", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "url"
    t.boolean  "status",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stations", :force => true do |t|
    t.string   "name"
    t.float    "lat"
    t.float    "lon"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name_a"
    t.string   "name_b"
    t.string   "name_c"
    t.string   "name_d"
    t.string   "name_e"
    t.string   "name_f"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",      :default => 0
  end

  add_index "tags", ["order"], :name => "index_tags_on_order"

  create_table "types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "types", ["id"], :name => "index_types_on_id"
  add_index "types", ["name"], :name => "index_types_on_name"

  create_table "user_preferences", :force => true do |t|
    t.integer  "user_id",                                                :null => false
    t.boolean  "dishin_email"
    t.boolean  "fb_friend_email"
    t.boolean  "start_following_me_email"
    t.boolean  "comment_email"
    t.boolean  "like_email"
    t.boolean  "following_email"
    t.boolean  "weekly_friends_activity_email"
    t.boolean  "ousted_as_top_expert_email"
    t.boolean  "unlock_new_level_email"
    t.boolean  "share_my_dishin_to_facebook"
    t.boolean  "share_my_like_to_facebook"
    t.boolean  "share_my_comments_to_facebook"
    t.boolean  "share_my_top_expert_to_facebook"
    t.boolean  "share_my_new_level_badge_to_facebook"
    t.boolean  "share_my_dishin_to_twitter"
    t.boolean  "share_my_like_to_twitter"
    t.boolean  "share_my_comments_to_twitter"
    t.boolean  "share_my_top_expert_to_twitter"
    t.boolean  "share_my_new_level_badge_to_twitter"
    t.boolean  "dishin_mobile"
    t.boolean  "fb_friend_mobile"
    t.boolean  "start_following_me_mobile"
    t.boolean  "comment_mobile"
    t.boolean  "like_mobile"
    t.boolean  "following_mobile"
    t.boolean  "ousted_as_top_expert_mobile"
    t.boolean  "unlock_new_level_mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "tagged_email",                         :default => true
    t.boolean  "tagged_mobile",                        :default => true
    t.boolean  "news_and_updates_email",               :default => true
    t.boolean  "news_and_updates_mobile",              :default => true
  end

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
    t.string   "twitter_id"
    t.string   "vkontakte_id"
    t.string   "gender"
    t.string   "current_city"
    t.string   "fb_access_token"
    t.string   "oauth_token_secret"
    t.string   "oauth_token"
    t.datetime "fb_valid_to"
    t.boolean  "force_logout",                              :default => false
  end

  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"
  add_index "users", ["remember_me_token"], :name => "index_users_on_remember_me_token"
  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id"

  create_table "work_hours", :force => true do |t|
    t.integer  "restaurant_id", :null => false
    t.string   "sun"
    t.string   "mon"
    t.string   "tue"
    t.string   "wed"
    t.string   "thu"
    t.string   "fri"
    t.string   "sat"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

