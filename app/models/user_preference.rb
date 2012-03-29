class UserPreference < ActiveRecord::Base
  belongs_to :user
  
  def self.for_user
    select([
      :add_to_favorites_my_dishin_email,
      :add_to_favorites_my_dishin_mobile,
      :comment_my_dishin_email,
      :comment_my_dishin_mobile,
      :friends_dishin_email,
      :friends_dishin_mobile,
      :friends_from_facebook_joins_email,
      :friends_from_facebook_joins_mobile,
      :news_and_updates_email,
      :news_and_updates_mobile,
      :ousted_as_top_expert_email,
      :ousted_as_top_expert_mobile,
      :share_my_comments_to_facebook,
      :share_my_comments_to_twitter,
      :share_my_dishin_to_facebook,
      :share_my_dishin_to_twitter,
      :share_my_dishin_to_twitter,
      :share_my_favorites_to_facebook,
      :share_my_favorites_to_twitter,
      :share_my_new_level_badge_to_facebook,
      :share_my_new_level_badge_to_twitter,
      :share_my_top_expert_to_facebook,
      :share_my_top_expert_to_twitter,
      :start_following_me_email,
      :start_following_me_mobile,
      :unlock_new_level_email,
      :unlock_new_level_mobile,
      :weekly_friends_activity_email,
      :weekly_friends_activity_mobile
    ])
  end
  
end
