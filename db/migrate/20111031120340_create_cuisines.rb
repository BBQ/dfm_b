class CreateCuisines < ActiveRecord::Migration
  def self.up
    create_table :cuisines, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name

      t.timestamps
    end
    add_index :cuisines, :id
    add_index :cuisines, :name
  end

  def self.down
    drop_table :cuisines
  end
end
