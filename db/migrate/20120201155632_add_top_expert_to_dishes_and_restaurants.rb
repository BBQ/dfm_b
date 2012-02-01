class AddTopExpertToDishesAndRestaurants < ActiveRecord::Migration
  def self.up
    add_column :dishes, :top_user_id, INT_UNSIGNED
    add_column :restaurants, :top_user_id, INT_UNSIGNED
  end

  def self.down
    remove_column :dishes, :top_user_id
    remove_column :restaurants, :top_user_id
  end
end
