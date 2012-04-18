class AddPushAllowAndEmailAllowToApnNotifications < ActiveRecord::Migration
  def self.up
    add_column :apn_notifications, :push_allow, :boolean, :default => true
    add_column :apn_notifications, :email_allow, :boolean, :default => true
    change_column_default('apn_notifications', 'read', 0)
  end

  def self.down
    remove_column :apn_notifications, :email_allow
    remove_column :apn_notifications, :push_allow
  end
end
