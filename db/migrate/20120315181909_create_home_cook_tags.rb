class CreateHomeCookTags < ActiveRecord::Migration
  def self.up
    create_table :home_cook_tags, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :tag_id, LINKED_ID_COLUMN
      t.column :home_cook_id, LINKED_ID_COLUMN

      t.timestamps
    end
    add_index :home_cook_tags, :id
    add_index :home_cook_tags, :tag_id
    add_index :home_cook_tags, :dish_id
  end

  def self.down
    drop_table :home_cook_tags
  end
end
