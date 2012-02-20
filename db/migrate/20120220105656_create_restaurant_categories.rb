class CreateRestaurantCategories < ActiveRecord::Migration
  def self.up
    create_table :restaurant_categories, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :restaurant_categories
  end
end
