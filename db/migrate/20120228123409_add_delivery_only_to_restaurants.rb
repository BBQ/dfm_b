class AddDeliveryOnlyToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :delivery_only, :boolean
  end

  def self.down
    remove_column :restaurants, :delivery_only
  end
end
