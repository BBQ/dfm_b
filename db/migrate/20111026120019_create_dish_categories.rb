class CreateDishCategories < ActiveRecord::Migration
  def self.up
    create_table :dish_categories do |t|
      t.string :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dish_categories
  end
end
