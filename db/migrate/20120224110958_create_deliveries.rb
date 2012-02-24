class CreateDeliveries < ActiveRecord::Migration
  def self.up
    create_table :deliveries, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name
      t.string :city
      t.string :address
      t.string :time      
      t.string :phone    
      t.string :web 
      t.text :description     
      t.string :photo                    
      t.double :lon
      t.double :lat
      t.column :votes, INT_UNSIGNED
      t.column :rating, INT_UNSIGNED      
      t.string :source
      
      t.timestamps
    end
    
    add_index :deliveries, :id    
    add_index :deliveries, :name
    add_index :deliveries, :city
    add_index :deliveries, :address
    
  end

  def self.down
    drop_table :deliveries
  end
end
