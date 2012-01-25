class CreateDishComments < ActiveRecord::Migration
  def self.up
    create_table :dish_comments, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :user_id, LINKED_ID_COLUMN
      t.column :dish_id, LINKED_ID_COLUMN
      t.text :text
      t.timestamps
    end
  end

  def self.down
    drop_table :dish_comments
  end
end
