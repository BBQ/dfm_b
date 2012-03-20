class CreateDeliveryTags < ActiveRecord::Migration
  def self.up
    create_table :delivery_tags, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :tag_id, LINKED_ID_COLUMN
      t.column :delivery_id, LINKED_ID_COLUMN

      t.timestamps
    end
    add_index :delivery_tags, :tag_id
    add_index :delivery_tags, :delivery_id

  end

  def self.down
    drop_table :delivery_tags
  end
end
