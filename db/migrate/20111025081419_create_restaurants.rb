class CreateRestaurants < ActiveRecord::Migration
  def self.up
    create_table :restaurants, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name
      t.string :city
      t.string :address
      t.string :time      
      t.string :phone    
      t.string :web 
      t.text :description
      t.string :breakfast   
      t.string :businesslunch          
      t.string :photo                    
      t.double :lon
      t.double :lat
      t.column :network_id, LINKED_ID_COLUMN
      t.column :votes, INT_UNSIGNED
      t.column :rating, INT_UNSIGNED      
      t.boolean :wifi, :default => 0
      t.boolean :chillum, :default => 0
      t.boolean :terrace, :default => 0
      t.boolean :cc, :default => 0
      t.string :source
      
      t.timestamps
    end
    add_index :restaurants, :id    
    add_index :restaurants, :name
    add_index :restaurants, :city
    add_index :restaurants, :address
    add_index :restaurants, :wifi
    add_index :restaurants, :chillum
    add_index :restaurants, :terrace
    add_index :restaurants, :cc
  end

  def self.down
    drop_table :restaurants
  end
end