class RenameSomeDbFields < ActiveRecord::Migration
  def self.up
    rename_column :user_preferences, :share_my_favorites_to_facebook, :share_my_likes_to_facebook
    rename_column :user_preferences, :share_my_favorites_to_twitter, :share_my_likes_to_twitter
    rename_column :user_preferences, :add_to_favorites_my_dishin_email, :likes_my_dishin_email
    rename_column :user_preferences, :add_to_favorites_my_dishin_mobile, :likes_my_dishin_mobile
  end
  
  def self.down
  end
end
