class AddTypeAndReviewIdToApnNotifications < ActiveRecord::Migration
  def self.up
    add_column :apn_notifications, :type, :string
    add_column :apn_notifications, :review_id, INT_UNSIGNED
  end

  def self.down
    remove_column :apn_notifications, :review_id
    remove_column :apn_notifications, :type
  end
end
