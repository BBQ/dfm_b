class CreateMiRestaurants < ActiveRecord::Migration
  def self.up
    create_table :mi_restaurants, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :address
      t.string :description
      t.string :dishes
      t.string :latitude
      t.string :longitude
      t.string :metro
      t.string :mi_id      
      t.string :name
      t.string :picture
      t.string :site
      t.string :telephone
      t.string :wifi
      t.string :worktime
      t.string :city

      t.timestamps
    end
  end

  def self.down
    drop_table :mi_restaurants
  end
end
