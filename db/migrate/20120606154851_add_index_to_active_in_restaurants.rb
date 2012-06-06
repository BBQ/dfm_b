class AddIndexToActiveInRestaurants < ActiveRecord::Migration
  def self.up
    add_index :restaurants, :active
  end

  def self.down
    remove_index :restaurants, :active
  end
end
