class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :photo
      t.string :uuid
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :images
  end
end
