class AddDeliveryIdToFavourite < ActiveRecord::Migration
  def self.up
    add_column :favourites, :delivery_id, INT_UNSIGNED, :default => 0
    add_column :favourites, :dish_delivery_id, INT_UNSIGNED, :default => 0
    add_column :favourites, :home_cook_id, INT_UNSIGNED, :default => 0    
    add_column :favourites, :network_id, INT_UNSIGNED, :default => 0    
    
    add_index :favourites, :delivery_id
    add_index :favourites, :home_cook_id
    add_index :favourites, :dish_delivery_id
    add_index :favourites, :network_id
  end

  def self.down
    remove_column :favourites, :delivery_id
    remove_column :favourites, :home_cook_id
    remove_column :favourites, :network_id
    remove_column :favourites, :dish_delivery_id
  end
end
