class CreateRestaurantTags < ActiveRecord::Migration  
  def self.up
    create_table :restaurant_tags, :id => false do |t|
      t.column :tag_id, LINKED_ID_COLUMN
      t.column :restaurant_id, LINKED_ID_COLUMN

      t.timestamps
    end
    add_index :restaurant_tags, :tag_id
    add_index :restaurant_tags, :restaurant_id

  end

  def self.down
    drop_table :restaurant_tags
  end
end
