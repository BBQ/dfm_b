class AddNetworkFieldsToDishes < ActiveRecord::Migration
  def self.up
    add_column :dishes, :network_rating, :integer
    add_column :dishes, :network_votes, :integer
    add_column :dishes, :network_fsq_users_count, :integer
  end

  def self.down
    remove_column :dishes, :network_fsq_users_count
    remove_column :dishes, :network_votes
    remove_column :dishes, :network_rating
  end
end
