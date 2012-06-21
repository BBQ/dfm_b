class AddActiveToRestaurantCategory < ActiveRecord::Migration
  def self.up
    add_column :restaurant_categories, :active, :boolean, :default => true
    add_index :restaurant_categories, :active
  end

  def self.down
    remove_column :restaurant_categories, :active
  end
end
