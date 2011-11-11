class CreateTypes < ActiveRecord::Migration
  def self.up
    create_table :types, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name

      t.timestamps
    end
    add_index :types, :id
    add_index :types, :name
  end

  def self.down
    drop_table :types
  end
end
