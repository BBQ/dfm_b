class CreateDishDeliveries < ActiveRecord::Migration
  def self.up
    create_table :dish_deliveries, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name
      t.string :photo
      t.column :price, INT_UNSIGNED
      t.string :currency
      t.column :rating, INT_UNSIGNED
      t.column :votes, INT_UNSIGNED      
      t.text :description
      t.column :delivery_id, INT_UNSIGNED
      t.column :dish_category_id, LINKED_ID_COLUMN
      t.column :dish_type_id, LINKED_ID_COLUMN
      t.column :dish_subtype_id, INT_UNSIGNED

      t.timestamps
    end
  end

  def self.down
    drop_table :dish_deliveries
  end
end
