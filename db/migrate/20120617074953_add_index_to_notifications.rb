class AddIndexToNotifications < ActiveRecord::Migration
  def self.up
    add_index :apn_notifications, :id
    add_index :apn_notifications, :review_id
    add_index :apn_notifications, :user_id_to
    add_index :apn_notifications, :user_id_from
    add_index :apn_notifications, :notification_type
  end

  def self.down
    remove_index :apn_notifications, :id
    remove_index :apn_notifications, :review_id
    remove_index :apn_notifications, :user_id_to
    remove_index :apn_notifications, :user_id_from
    remove_index :apn_notifications, :notification_type    
  end
end
