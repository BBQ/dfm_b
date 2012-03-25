class Add4sqToYlpRestaurants < ActiveRecord::Migration
  def self.up
    add_column :ylp_restaurants, :fsq_id, :string
    add_column :ylp_restaurants, :fsq_name, :string
    add_column :ylp_restaurants, :fsq_address, :string
    add_column :ylp_restaurants, :fsq_lat, :string
    add_column :ylp_restaurants, :fsq_lng, :string
    add_column :ylp_restaurants, :fsq_checkins_count, :string
    add_column :ylp_restaurants, :fsq_users_count, :string
    add_column :ylp_restaurants, :fsq_tip_count, :string
    add_column :ylp_restaurants, :restaurant_categories, :string
    add_column :ylp_restaurants, :city, :string
    add_column :ylp_restaurants, :has_menu, :boolean
    
    add_index :ylp_restaurants, :fsq_id
  end

  def self.down
    remove_column :ylp_restaurants, :fsq_id
    remove_column :ylp_restaurants, :fsq_name
    remove_column :ylp_restaurants, :fsq_address
    remove_column :ylp_restaurants, :fsq_lat
    remove_column :ylp_restaurants, :fsq_lng
    remove_column :ylp_restaurants, :fsq_checkins_count
    remove_column :ylp_restaurants, :fsq_users_count
    remove_column :ylp_restaurants, :fsq_tip_count
    remove_column :ylp_restaurants, :restaurant_categories
    remove_column :ylp_restaurants, :city
    remove_column :ylp_restaurants, :has_menu
  end
end
