class AddNetworkIdToMiRestaurants < ActiveRecord::Migration
  def self.up
    add_column :mi_restaurants, :network_id, :integer
  end

  def self.down
    remove_column :mi_restaurants, :network_id
  end
end
