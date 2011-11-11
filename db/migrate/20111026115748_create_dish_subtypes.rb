class CreateDishSubtypes < ActiveRecord::Migration
  def self.up
    create_table :dish_subtypes do |t|
      t.string :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dish_subtypes
  end
end
