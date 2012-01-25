class RemoveRestaurantIdFromDishes < ActiveRecord::Migration
  def self.up
    remove_column :dishes, :restaurant_id
  end

  def self.down
    add_column :dishes, :restaurant_id, :integer
  end
end
