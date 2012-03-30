class RenameSomeDbFields < ActiveRecord::Migration
  def self.up
    rename_column :user_preferences, :share_my_favorites_to_facebook, :share_my_like_to_facebook
    rename_column :user_preferences, :share_my_favorites_to_twitter, :share_my_like_to_twitter
    rename_column :user_preferences, :add_to_favorites_my_dishin_email, :like_email
    rename_column :user_preferences, :add_to_favorites_my_dishin_mobile, :like_mobile
    
    rename_column :user_preferences, :comment_my_dishin_email, :comment_email
    rename_column :user_preferences, :comment_my_dishin_mobile, :comment_mobile
    rename_column :user_preferences, :friends_dishin_email, :dishin_email
    rename_column :user_preferences, :friends_dishin_mobile, :dishin_mobile
    rename_column :user_preferences, :friends_from_facebook_joins_email, :fb_friend_email
    rename_column :user_preferences, :friends_from_facebook_joins_mobile, :fb_friend_mobile
    rename_column :user_preferences, :news_and_updates_email, :following_email
    rename_column :user_preferences, :news_and_updates_mobile, :following_mobile
    
    add_column :user_preferences, :tagged_email, :boolean
    add_column :user_preferences, :tagged_mobile, :boolean
  end
  
  def self.down
  end
end
