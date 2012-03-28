class CleanUpUserPreferences < ActiveRecord::Migration
  def self.up
    remove_column :user_preferences, :share_my_dishin_to_facebook_mobile
    remove_column :user_preferences, :share_my_favorites_to_facebook_mobile
    remove_column :user_preferences, :share_my_comments_to_facebook_mobile
    remove_column :user_preferences, :share_my_top_expert_to_facebook_mobile
    remove_column :user_preferences, :share_my_new_level_badge_to_facebook_mobile
    remove_column :user_preferences, :share_my_dishin_to_twitter_mobile
    remove_column :user_preferences, :share_my_favorites_to_twitter_mobile
    remove_column :user_preferences, :share_my_comments_to_twitter_mobile
    remove_column :user_preferences, :share_my_top_expert_to_twitter_mobile
    remove_column :user_preferences, :share_my_new_level_badge_to_twitter_mobile
    
    rename_column :user_preferences, :share_my_dishin_to_facebook_email, :share_my_dishin_to_facebook
    rename_column :user_preferences, :share_my_favorites_to_facebook_email, :share_my_favorites_to_facebook
    rename_column :user_preferences, :share_my_comments_to_facebook_email, :share_my_comments_to_facebook
    rename_column :user_preferences, :share_my_top_expert_to_facebook_email, :share_my_top_expert_to_facebook
    rename_column :user_preferences, :share_my_new_level_badge_to_facebook_email, :share_my_new_level_badge_to_facebook
    rename_column :user_preferences, :share_my_dishin_to_twitter_email, :share_my_dishin_to_twitter
    rename_column :user_preferences, :share_my_favorites_to_twitter_email, :share_my_favorites_to_twitter
    rename_column :user_preferences, :share_my_comments_to_twitter_email, :share_my_comments_to_twitter
    rename_column :user_preferences, :share_my_top_expert_to_twitter_email, :share_my_top_expert_to_twitter
    rename_column :user_preferences, :share_my_new_level_badge_to_twitter_email, :share_my_new_level_badge_to_twitter
  end

  def self.down
  end
end
