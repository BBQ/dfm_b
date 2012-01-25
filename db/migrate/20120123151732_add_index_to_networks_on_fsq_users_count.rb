class AddIndexToNetworksOnFsqUsersCount < ActiveRecord::Migration
  def self.up
    add_index :networks, :fsq_users_count
  end

  def self.down
  end
end
