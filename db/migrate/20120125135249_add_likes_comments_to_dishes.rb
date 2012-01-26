class AddLikesCommentsToDishes < ActiveRecord::Migration
  def self.up
    add_column :dishes, :count_likes, :integer, :default => 0
    add_column :dishes, :count_comments, :integer, :default => 0
  end

  def self.down
    remove_column :dishes, :count_comments
    remove_column :dishes, :count_likes
  end
end
