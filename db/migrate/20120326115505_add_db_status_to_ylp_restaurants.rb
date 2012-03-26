class AddDbStatusToYlpRestaurants < ActiveRecord::Migration
  def self.up
    add_column :ylp_restaurants, :db_status, :integer
    add_column :ylp_restaurants, :our_network_id, :integer
  end

  def self.down
    remove_column :ylp_restaurants, :db_status
    remove_column :ylp_restaurants, :our_network_id
  end
end
