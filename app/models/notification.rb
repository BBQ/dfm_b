class Notification < ActiveRecord::Base
  
  def self.send(user_id_from, notification_type, user_id_to = nil, dish_name = nil, restaurant_name = nil, friends = nil, review_id = nil)
    
    user_id_from = user_id_from.to_i
    user_id_to = user_id_to.to_i
    review_id = review_id.to_i
    
    # :like_email,
    # :like_mobile,
    # :comment_email,
    # :comment_mobile,
    # :dishin_email,
    # :dishin_mobile,
    # :fb_friend_email,
    # :fb_friend_mobile,
    # :following_email,
    # :following_mobile, 
    # :tagged_mobile
    # tagged_email
    # :unlock_new_level_email,
    # :unlock_new_level_mobile,
    # :weekly_friends_activity_email,
    # :weekly_friends_activity_mobile   
    # :news_and_updates_email,
    # :news_and_updates_mobile,
    # :ousted_as_top_expert_email,
    # :ousted_as_top_expert_mobile,
    # :share_my_comments_to_facebook,
    # :share_my_comments_to_twitter,
    # :share_my_dishin_to_facebook,
    # :share_my_dishin_to_twitter,
    # :share_my_dishin_to_twitter,
    # :share_my_like_to_facebook,
    # :share_my_like_to_twitter,
    # :share_my_new_level_badge_to_facebook,
    # :share_my_new_level_badge_to_twitter,
    # :share_my_top_expert_to_facebook,
    # :share_my_top_expert_to_twitter,
    
    (pref.like_mobile == true && notification_type == 'like') ||
       (pref.comment_mobile == true && notification_type == 'comment') ||
       (pref.dishin_mobile == true && notification_type == 'dishin') ||
       (pref.fb_friend_mobile == true && notification_type == 'fb_friend') ||
       (pref.following_mobile == true && notification_type == 'following') ||
       (pref.tagged_mobile == true && (notification_type == 'tagged' || notification_type == 'tagged_by_friend')) ||
       (pref.unlock_new_level_mobile == true && notification_type == 'unlock_new_level') ||
       (pref.weekly_friends_activity_mobile == true && notification_type == 'weekly_friends_activity') ||
       (pref.news_and_updates_mobile == true && notification_type == 'news_and_updates') ||
       (pref.top_expert_mobile == true && notification_type == 'top_expert') ||
       (pref.ousted_as_top_expert_mobile == true && notification_type == 'ousted_as_top_expert')

    
    pref = UserPreference.find_by_user_id(user_id_to)
    
    if user = User.select(:name).find_by_id(user_id_from) && notification_type
      user_ids_to_array = []
      
      if (notification_type == 'like' && pref.like_mobile == true) || (pref.comment_mobile == true && notification_type == 'comment')
        if (user_id_from != user_id_to) && dish_name && review_id
        
              if notification_type == 'like'
                alert = "Liked your dish-in in #{dish_name} "
              elsif notification_type == 'comment'
                alert = "Commented on your dish-in in #{dish_name} "
              end
                
              badge = APN::Notification.where("user_id_to = ? and `read` != 1", user_id_to).count(:id)
              user_ids_to_array.push({:user_id => user_id_to, :badge => badge})
        end
      elsif notification_type == 'comment_on_comment' && pref.comment_mobile == true && user_id_to && review_id 
              alert = "Also commented on #{dish_name}"              
              
              Comment.select([:user_id, :review_id]).where(:review_id => review_id).group(:user_id).each do |c|
                  if c.user_id != c.review.user_id
                    badge = APN::Notification.where("user_id_to = ? and `read` != 1", c.user_id).count(:id)
                    user_ids_to_array.push({:user_id => c.user_id, :badge => badge}) if c.user_id.to_i != user_id_from
                  end               
              end
              
      elsif notification_type == 'dishin' && pref.dishin_mobile == true && dish_name
              alert = "Dished in #{dish_name}"        
                    
              Follower.select(:user_id).where(:follow_user_id => user_id_from).each do |f|
                  if user = User.find_by_id(f.user_id)
                    
                    badge = APN::Notification.where("user_id_to = ? and `read` != 1", f.user_id).count(:id)
                    user_ids_to_array.push({:user_id => f.user_id, :badge => badge}) if f.user_id.to_i != user_id_from
                    
                  end
                  
              end    
           
      elsif notification_type == 'following' && pref.following_mobile == true && user_id_to && user_id_from != user_id_to 
        
              alert = "Started following you"
              badge = APN::Notification.where("user_id_to = ? AND `read` != 1", user_id_to).count(:id)
              
              user_ids_to_array.push({:user_id => user_id_to, :badge => badge})
              
      elsif notification_type == 'tagged' && pref.tagged_mobile == true && friends && review_id
        
              if r = Review.find_by_id(review_id)

                if r.rtype == 'home_cooked'
                  d = HomeCooke.find_by_id(r.dish_id) 
                elsif r.rtype == 'delivery'
                  d = DishDelivery.find_by_id(r.dish_id) 
                else  
                  d = Dish.find_by_id(r.dish_id)
                end
                
                unless d.nil?
                  alert = restaurant_name.nil? ? "Tagged you in dish-in #{d.name}" : "Tagged you at #{restaurant_name}"
              
                  friends.split(',').each do |t|  
                      if user = User.find_by_id(t)
                    
                        badge = APN::Notification.where("user_id_to = ? and `read` != 1", t).count(:id)
                        user_ids_to_array.push({:user_id => t, :badge => badge}) if t.to_i != user_id_from
                    
                      end
                
                  end
                end
              end
      elsif notification_type == 'tagged_by_friend' && pref.tagged_mobile == true && restaurant_name && friends
              if review = Review.find_by_id(review_id)
                                
                  if review.user_id != user_id_from
                      friends.split(',').each do |t|
      
                          if tagged = User.find_by_id(t)
                              alert = restaurant_name.nil? ? "Tagged your friend #{t.name} in dish-in" : "Tagged your friend #{t.name} at #{restaurant_name}"
                                                            
                              Follower.select(:user_id).where(:follow_user_id => tagged.id).each do |f|
                                  if user = User.find_by_id(f.user_id)

                                    badge = APN::Notification.where("user_id_to = ? and `read` != 1", f.user_id).count(:id)
                                    user_ids_to_array.push({:user_id => f.user_id, :badge => badge}) if f.user_id.to_i != user_id_from
                  
                                  end
                              end                  
                          end
                      end 
                  end 
              end

      elsif notification_type == 'fb_friend' && pref.fb_friend_mobile == true && user_id_from != user_id_to
         
              alert = "Your friend from facebook has joined Dish.fm"
              badge = APN::Notification.where("user_id_to = ? and `read` != 1", user_id_to).count(:id)
              user_ids_to_array.push({:user_id => user_id_to, :badge => badge})
        
      end

      if user_ids_to_array.count > 0
        
        send = 0
        user_ids_to_array.each do |u|

            if device = APN::Device.find_by_user_id(u[:user_id])
              send = 1
            else
              device = APN::Device.new
              device.id = 0
            end

            notification = APN::Notification.new
            notification.device = device
            notification.badge = u[:badge]  
            notification.sound = 'default'   
            notification.alert = alert
            notification.notification_type = notification_type
            notification.review_id = review_id ? review_id : 0
            notification.user_id_from = user_id_from
            notification.user_id_to = u[:user_id]
            notification.read = 0
            notification.save
            
        end
        
        if send == 1
          system "rake apn:notifications:deliver &" if (pref.like_mobile == true && notification_type == 'like') ||
             (pref.comment_mobile == true && notification_type == 'comment') ||
             (pref.dishin_mobile == true && notification_type == 'dishin') ||
             (pref.fb_friend_mobile == true && notification_type == 'fb_friend') ||
             (pref.following_mobile == true && notification_type == 'following') ||
             (pref.unlock_new_level_mobile == true && notification_type == 'unlock_new_level') ||
             (pref.weekly_friends_activity_mobile == true && notification_type == 'weekly_friends_activity') ||
             (pref.news_and_updates_mobile == true && notification_type == 'news_and_updates') ||
             (pref.top_expert_mobile == true && notification_type == 'top_expert') ||
             (pref.ousted_as_top_expert_mobile == true && notification_type == 'ousted_as_top_expert')
             
          system "rake email:notifications:deliver &" if (pref.like_email == true && notification_type == 'like') ||
            (pref.comment_email == true && notification_type == 'comment') ||
            (pref.dishin_email == true && notification_type == 'dishin') ||
            (pref.fb_friend_email == true && notification_type == 'fb_friend') ||
            (pref.following_email == true && notification_type == 'following') ||
            (pref.unlock_new_level_email == true && notification_type == 'unlock_new_level') ||
            (pref.weekly_friends_activity_email == true && notification_type == 'weekly_friends_activity') ||
            (pref.news_and_updates_email == true && notification_type == 'news_and_updates') ||
            (pref.top_expert_email == true && notification_type == 'top_expert') ||
            (pref.ousted_as_top_expert_email == true && notification_type == 'ousted_as_top_expert')
        end
      end
      
    end
  end
  
end
