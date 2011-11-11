class CreateRestaurantStations < ActiveRecord::Migration
  def self.up
    create_table :restaurant_stations, :id => false do |t|
      t.column :restaurant_id, LINKED_ID_COLUMN
      t.column :station_id, LINKED_ID_COLUMN

      t.timestamps
    end
  end

  def self.down
    drop_table :restaurant_stations
  end
end
