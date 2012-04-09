class AddIndexToUsersOnTwitterId < ActiveRecord::Migration
  def self.up
    add_index :users, :twitter_id
  end

  def self.down
    remove_index :users, :twitter_id
  end
end
