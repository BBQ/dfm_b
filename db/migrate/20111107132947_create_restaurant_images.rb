class CreateRestaurantImages < ActiveRecord::Migration
  def self.up
    create_table :restaurant_images, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :restaurant_id, LINKED_ID_COLUMN
      t.string :photo

      t.timestamps
    end
  end

  def self.down
    drop_table :restaurant_images
  end
end
