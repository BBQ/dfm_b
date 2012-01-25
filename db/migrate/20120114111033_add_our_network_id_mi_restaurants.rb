class AddOurNetworkIdMiRestaurants < ActiveRecord::Migration
  def self.up
    add_column :mi_restaurants, :our_network_id, :integer
  end

  def self.down
    remove_column :mi_restaurants, :our_network_id
  end
end
