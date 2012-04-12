class CreateFavourites < ActiveRecord::Migration
  def self.up
    create_table :favourites, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :dish_id, INT_UNSIGNED, :default => 0
      t.column :restaurant_id, INT_UNSIGNED, :default => 0
      t.column :user_id, INT_UNSIGNED, :default => 0      

      t.timestamps
    end
    
    add_index :favourites, :dish_id
    add_index :favourites, :restaurant_id
    add_index :favourites, :user_id
  end

  def self.down
    drop_table :favourites
  end
end
