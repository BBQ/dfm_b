class CreateYlpRestaurants < ActiveRecord::Migration
  def self.up
    create_table :ylp_restaurants, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name
      t.string :ylp_uri
      t.string :lat
      t.string :lng
      t.string :rating
      t.string :review_count
      t.string :category
      t.string :address
      t.string :phone
      t.string :web
      t.string :transit
      t.string :hours
      t.string :parking
      t.string :cc
      t.string :price
      t.string :attire
      t.string :groups
      t.string :kids
      t.string :reservation
      t.string :delivery
      t.string :takeout
      t.string :table_service
      t.string :outdoor_seating
      t.string :wifi
      t.string :meal
      t.string :alcohol
      t.string :noise
      t.string :ambience
      t.string :tv
      t.string :caters
      t.string :wheelchair_accessible

      t.timestamps
    end
    
    add_index :ylp_restaurants, :ylp_uri
  end

  def self.down
    drop_table :ylp_restaurants
  end
end
