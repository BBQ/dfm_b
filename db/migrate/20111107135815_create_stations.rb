class CreateStations < ActiveRecord::Migration
  def self.up
    create_table :stations do |t|
      t.column :id, ID_COLUMN
      t.string :name
      t.double :lat
      t.double :lon
      t.string :color      

      t.timestamps
    end
  end

  def self.down
    drop_table :stations
  end
end
