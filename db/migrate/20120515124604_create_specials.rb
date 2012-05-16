class CreateSpecials < ActiveRecord::Migration
  def self.up
    create_table :specials, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :name, :string
      t.column :description, :string
      t.column :url, :string
      t.column :status, :boolean, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :specials
  end
end
