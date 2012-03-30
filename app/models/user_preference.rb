class UserPreference < ActiveRecord::Base
  belongs_to :user
  
  def self.for_user
    select([
      :like_email,
      :like_mobile,
      :comment_email,
      :comment_mobile,
      :dishin_email,
      :dishin_mobile,
      :fb_friend_email,
      :fb_friend_mobile,
      :following_email,
      :following_mobile, 
      :tagged_mobile
      :tagged_email
      :unlock_new_level_email,
      :unlock_new_level_mobile,
      :weekly_friends_activity_email,
      :weekly_friends_activity_mobile   
      :news_and_updates_email,
      :news_and_updates_mobile,
      :ousted_as_top_expert_email,
      :ousted_as_top_expert_mobile,
      :share_my_comments_to_facebook,
      :share_my_comments_to_twitter,
      :share_my_dishin_to_facebook,
      :share_my_dishin_to_twitter,
      :share_my_dishin_to_twitter,
      :share_my_like_to_facebook,
      :share_my_like_to_twitter,
      :share_my_new_level_badge_to_facebook,
      :share_my_new_level_badge_to_twitter,
      :share_my_top_expert_to_facebook,
      :share_my_top_expert_to_twitter,
    ])
  end
  
end
