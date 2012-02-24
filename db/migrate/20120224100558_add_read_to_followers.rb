class AddReadToFollowers < ActiveRecord::Migration
  def self.up
    add_column :followers, :read, :boolean
  end

  def self.down
    remove_column :followers, :read
  end
end
