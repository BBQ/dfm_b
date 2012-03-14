class AddReadToapnNotifications < ActiveRecord::Migration
  def self.up
    add_column :apn_notifications, :read, :boolean
  end

  def self.down
    remove_column :apn_notifications, :read
  end
end
