class CreateYlpDishes < ActiveRecord::Migration
  def self.up
    create_table :ylp_dishes, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :ylp_restaurant_id
      t.string :name
      t.string :price
      t.string :currency
      t.string :description
      t.string :dish_category

      t.timestamps
    end
    
    add_index :ylp_dishes, :id
    add_index :ylp_dishes, :ylp_restaurant_id
    add_index :ylp_dishes, :name
  end

  def self.down
    drop_table :ylp_dishes
  end
end
