class CreateDishExtratypes < ActiveRecord::Migration
  def self.up
    create_table :dish_extratypes, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name

      t.timestamps
    end
    add_index :dish_extratypes, :id
    add_index :dish_extratypes, :name
  end

  def self.down
    drop_table :dish_extratypes
  end
end