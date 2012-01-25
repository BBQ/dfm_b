class AddHasMenuToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :has_menu, :tinyint
  end

  def self.down
    remove_column :restaurants, :has_menu
  end
end
