class AddIndexesToFriends < ActiveRecord::Migration
  def self.up
    add_index :friends, [:friend_id, :user_id]
    add_index :friends, [:user_id, :friend_id]
  end

  def self.down
    remove_index :friends, [:user_id, :friend_id]
    remove_index :friends, [:friend_id, :user_id]
  end
end
