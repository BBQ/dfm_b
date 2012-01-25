class AddFsqUsersCountToNetworks < ActiveRecord::Migration
  def self.up
    add_column :networks, :fsq_users_count, :integer
  end

  def self.down
    remove_column :networks, :fsq_users_count
  end
end
