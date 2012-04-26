class AddForceLogoutToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :force_logout, :boolean, :default => 0
  end

  def self.down
    remove_column :users, :force_logout
  end
end
