class AddCountDishesToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :count_dishes, INT_UNSIGNED
  end

  def self.down
    remove_column :restaurants, :count_dishes
  end
end
