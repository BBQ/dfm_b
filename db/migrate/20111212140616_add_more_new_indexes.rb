class AddMoreNewIndexes < ActiveRecord::Migration
  def self.up
    add_index :likes, [:user_id, :review_id]
    add_index :users, :facebook_id
    add_index :networks, :id
  end

  def self.down
  end
end
