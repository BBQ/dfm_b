class AddUserFromAndUserToToApnNotifications < ActiveRecord::Migration
  def self.up
    add_column :apn_notifications, :user_to, LINKED_ID_COLUMN
    add_column :apn_notifications, :user_from, LINKED_ID_COLUMN
  end

  def self.down
    remove_column :apn_notifications, :user_from
    remove_column :apn_notifications, :user_to
  end
end
