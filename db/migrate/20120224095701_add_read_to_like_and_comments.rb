class AddReadToLikeAndComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :read, :boolean
    add_column :likes, :read, :boolean
  end

  def self.down
    remove_column :comments, :read
    remove_column :likes, :read
  end
end
