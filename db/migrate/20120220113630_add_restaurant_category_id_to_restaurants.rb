class AddRestaurantCategoryIdToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :restaurant_category_id, INT_UNSIGNED
  end

  def self.down
  end
end
