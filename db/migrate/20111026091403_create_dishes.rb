class CreateDishes < ActiveRecord::Migration
  def self.up
    create_table :dishes, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name
      t.string :photo
      t.column :price, INT_UNSIGNED
      t.string :currency
      t.column :rating, INT_UNSIGNED
      t.column :votes, INT_UNSIGNED      
      t.text :description
      t.column :restaurant_id, INT_UNSIGNED
      t.column :network_id, INT_UNSIGNED 
      t.column :dish_category_id, LINKED_ID_COLUMN
      t.column :dish_type_id, LINKED_ID_COLUMN
      t.column :dish_subtype_id, LINKED_ID_COLUMN

      t.timestamps
    end
  end

  def self.down
    drop_table :dishes
  end
end