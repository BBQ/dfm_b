class AddActiveToApnDevices < ActiveRecord::Migration
  def self.up
    add_column :apn_devices, :active, :boolean, :default => true
  end

  def self.down
    remove_column :apn_devices, :active
  end
end
