class CreateDishTags < ActiveRecord::Migration  
  def self.up
    create_table :dish_tags, :id => false do |t|
      t.column :id, ID_COLUMN,
      t.column :tag_id, LINKED_ID_COLUMN
      t.column :dish_id, LINKED_ID_COLUMN

      t.timestamps
    end
    add_index :dish_tags, :id
    add_index :dish_tags, :tag_id
    add_index :dish_tags, :dish_id

  end

  def self.down
    drop_table :dish_tags
  end
end
