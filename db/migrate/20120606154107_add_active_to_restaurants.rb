class AddActiveToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :active, :boolean, :default => true
  end

  def self.down
    remove_column :restaurants, :active
  end
end
