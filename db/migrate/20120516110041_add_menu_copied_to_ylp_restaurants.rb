class AddMenuCopiedToYlpRestaurants < ActiveRecord::Migration
  def self.up
    add_column :ylp_restaurants, :menu_copied, :boolean, :default => false
  end

  def self.down
    remove_column :ylp_restaurants, :menu_copied
  end
end
