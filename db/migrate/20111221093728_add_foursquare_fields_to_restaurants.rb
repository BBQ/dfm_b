class AddFoursquareFieldsToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :fsq_checkins_count, :string
    add_column :restaurants, :fsq_tip_count, :string
    add_column :restaurants, :fsq_users_count, :string
    add_column :restaurants, :fsq_name, :string
    add_column :restaurants, :fsq_address, :string
    add_column :restaurants, :fsq_lat, :string
    add_column :restaurants, :fsq_lng, :string
  end

  def self.down
    remove_column :restaurants, :fsq_checkins_count
    remove_column :restaurants, :fsq_tip_count
    remove_column :restaurants, :fsq_users_count
    remove_column :restaurants, :fsq_name
    remove_column :restaurants, :fsq_address
    remove_column :restaurants, :fsq_lat
    remove_column :restaurants, :fsq_lng
  end
end
