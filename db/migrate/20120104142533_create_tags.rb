class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name

      t.timestamps
    end
    add_index :tags, :id
    add_index :tags, :name
  end

  def self.down
    drop_table :tags
  end
end
