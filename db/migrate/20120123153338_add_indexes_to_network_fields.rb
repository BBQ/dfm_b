class AddIndexesToNetworkFields < ActiveRecord::Migration
  def self.up
    add_index :dishes, :network_rating
    add_index :dishes, :network_votes
    add_index :dishes, :network_fsq_users_count
  end

  def self.down
  end
end
