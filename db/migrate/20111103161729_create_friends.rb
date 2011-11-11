class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friends, :id => false do |t|
      t.column :user_id, LINKED_ID_COLUMN_BIGINT
      t.column :friend_id, LINKED_ID_COLUMN_BIGINT
      t.string :friend_name
      t.string :provider
      
      t.timestamps
    end
  end

  def self.down
    drop_table :friends
  end
end
