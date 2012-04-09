class AddTimeZoneToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :time_zone_offset, :string
  end

  def self.down
    remove_column :restaurants, :time_zone_offset
  end
end
