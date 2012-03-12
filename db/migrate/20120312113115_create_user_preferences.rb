class CreateUserPreferences < ActiveRecord::Migration
  def self.up
    create_table :user_preferences, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :user_id, LINKED_ID_COLUMN

      t.boolean :friends_dishin_email
      t.boolean :friends_from_facebook_joins_email
      t.boolean :start_following_me_email
      
      t.boolean :comment_my_dishin_email
      t.boolean :add_to_favorites_my_dishin_email
      
      t.boolean :news_and_updates_email
      t.boolean :weekly_friends_activity_email
      
      t.boolean :ousted_as_top_expert_email
      t.boolean :unlock_new_level_email
      
      t.boolean :share_my_dishin_to_facebook_email
      t.boolean :share_my_favorites_to_facebook_email
      t.boolean :share_my_comments_to_facebook_email
      t.boolean :share_my_top_expert_to_facebook_email
      t.boolean :share_my_new_level_badge_to_facebook_email
      
      t.boolean :share_my_dishin_to_twitter_email
      t.boolean :share_my_favorites_to_twitter_email
      t.boolean :share_my_comments_to_twitter_email
      t.boolean :share_my_top_expert_to_twitter_email
      t.boolean :share_my_new_level_badge_to_twitter_email
      
      t.boolean :friends_dishin_mobile
      t.boolean :friends_from_facebook_joins_mobile
      t.boolean :start_following_me_mobile
      
      t.boolean :comment_my_dishin_mobile
      t.boolean :add_to_favorites_my_dishin_mobile
      
      t.boolean :news_and_updates_mobile
      t.boolean :weekly_friends_activity_mobile
      
      t.boolean :ousted_as_top_expert_mobile
      t.boolean :unlock_new_level_mobile
      
      t.boolean :share_my_dishin_to_facebook_mobile
      t.boolean :share_my_favorites_to_facebook_mobile
      t.boolean :share_my_comments_to_facebook_mobile
      t.boolean :share_my_top_expert_to_facebook_mobile
      t.boolean :share_my_new_level_badge_to_facebook_mobile
      
      t.boolean :share_my_dishin_to_twitter_mobile
      t.boolean :share_my_favorites_to_twitter_mobile
      t.boolean :share_my_comments_to_twitter_mobile
      t.boolean :share_my_top_expert_to_twitter_mobile
      t.boolean :share_my_new_level_badge_to_twitter_mobile
      
      t.timestamps
    end
  end

  def self.down
    drop_table :user_preferences
  end
end
