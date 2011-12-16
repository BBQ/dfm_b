class CreateDishCategoryOrders < ActiveRecord::Migration
  def self.up
    create_table :dish_category_orders, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :restaurant_id, LINKED_ID_COLUMN
      t.column :network_id, LINKED_ID_COLUMN
      t.column :dish_category_id, LINKED_ID_COLUMN
      t.column :order, INT_UNSIGNED
      t.timestamps
    end
    add_index :dish_category_orders, :id
    add_index :dish_category_orders, :restaurant_id
    add_index :dish_category_orders, :network_id
    add_index :dish_category_orders, :dish_category_id
  end

  def self.down
    drop_table :dish_category_orders
  end
end
