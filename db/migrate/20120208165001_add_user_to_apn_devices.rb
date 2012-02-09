class AddUserToApnDevices < ActiveRecord::Migration
  def self.up
    add_column :apn_devices, :user_id, INT_UNSIGNED
  end

  def self.down
    remove_column :apn_devices, :user
  end
end
