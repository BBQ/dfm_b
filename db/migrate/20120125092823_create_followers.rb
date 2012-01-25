class CreateFollowers < ActiveRecord::Migration
  def self.up
    create_table :followers, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :user_id, LINKED_ID_COLUMN
      t.column :follow_user_id, LINKED_ID_COLUMN

      t.timestamps
    end
  end

  def self.down
    drop_table :followers
  end
end
