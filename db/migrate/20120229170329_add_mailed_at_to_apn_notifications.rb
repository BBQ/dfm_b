class AddMailedAtToApnNotifications < ActiveRecord::Migration
  def self.up
    add_column :apn_notifications, :mailed_at, :datetime
  end

  def self.down
    remove_column :apn_notifications, :mailed_at
  end
end
