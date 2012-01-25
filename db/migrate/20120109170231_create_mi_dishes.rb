class CreateMiDishes < ActiveRecord::Migration
  def self.up
    create_table :mi_dishes, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :category_id
      t.string :category_name
      t.string :category_picture
      t.string :description
      t.string :mi_id
      t.string :kilo_calories
      t.string :cousine      
      t.string :latitude
      t.string :longitude
      t.string :likes
      t.string :name
      t.string :pictures
      t.string :price
      t.string :restaurant_id
      t.string :restaurant_name
      t.string :composition
      t.string :vegetarian
      t.string :weight

      t.timestamps
    end
  end

  def self.down
    drop_table :mi_dishes
  end
end
