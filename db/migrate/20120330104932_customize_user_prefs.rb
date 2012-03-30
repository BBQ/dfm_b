class CustomizeUserPrefs < ActiveRecord::Migration
  def self.up
    add_column :user_preferences, :news_and_updates_email, :boolean
    add_column :user_preferences, :news_and_updates_mobile, :boolean

    remove_column :user_preferences, :weekly_friends_activity_mobile    
  end

  def self.down
  end
end
