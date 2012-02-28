class AddFriendsWithToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :friends, :string
  end

  def self.down
    remove_column :reviews, :friends
  end
end
