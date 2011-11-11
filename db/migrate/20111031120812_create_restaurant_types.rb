class CreateRestaurantTypes < ActiveRecord::Migration
  def self.up
      create_table :restaurant_types, :id => false do |t|
          t.references :restaurant
          t.references :type
      end
      add_index :restaurant_types, [:restaurant_id, :type_id]
      add_index :restaurant_types, [:type_id, :restaurant_id]
    end

    def self.down
      drop_table :restaurant_types
    end
end
