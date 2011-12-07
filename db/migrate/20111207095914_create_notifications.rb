class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications, :id => false do |t|
      t.column :id, ID_COLUMN
      t.integer :user_id
      t.integer :comment_id
      t.integer :like_id

      t.timestamps
    end
    add_index :notifications, :id
    add_index :notifications, :user_id
    add_index :notifications, :comment_id
    add_index :notifications, :like_id
  end

  def self.down
    drop_table :notifications
  end
end
