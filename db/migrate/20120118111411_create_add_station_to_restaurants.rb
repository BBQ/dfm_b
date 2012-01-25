class CreateAddStationToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :station, :string
  end

  def self.down
    remove_column :restaurants, :station
  end
end
