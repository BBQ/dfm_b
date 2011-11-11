class CreateRestaurantCuisines < ActiveRecord::Migration
  def self.up
      create_table :restaurant_cuisines, :id => false do |t|
          t.references :restaurant
          t.references :cuisine
      end
      add_index :restaurant_cuisines, [:restaurant_id, :cuisine_id]
      add_index :restaurant_cuisines, [:cuisine_id, :restaurant_id]
    end

    def self.down
      drop_table :restaurant_cuisines
    end
end
