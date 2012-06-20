class Notification < ActiveRecord::Base
  def self.send(user_id_from, notification_type, user_id_to = nil, review = nil)
    
    user_id_from = user_id_from.to_i
    user_id_to = user_id_to.to_i
    
    if user = User.select(:name).find_by_id(user_id_from) && notification_type
      user_to_array = []  
      
      if review && (
        notification_type == 'tagged' || notification_type == 'tagged_by_friend' || 
        notification_type == 'comment' || notification_type == 'comment_on_comment' ||
        notification_type == 'dishin' || notification_type == 'like')
        
        case review.rtype
        when 'home_cooked'
          dish_name = review.home_cook.name
          restaurant_name = nil
        when 'delivery'
          dish_name = review.dish_delivery.name
          restaurant_name = review.delivery.name 
        else
          dish_name = review.dish.name
          restaurant_name = review.restaurant.name
        end
        
        if notification_type == 'dishin'
          Follower.select(:user_id).where(:follow_user_id => user_id_from).each do |f|
              if user = User.find_by_id(f.user_id)

                badge = APN::Notification.where("user_id_to = ? and `read` != 1", f.user_id).count(:id)
                user_to_array.push({:user_id => f.user_id, :badge => badge}) if f.user_id.to_i != user_id_from

              end
          end
        elsif notification_type == 'like' || notification_type == 'comment'
          if user_id_from != review.user_id 
            
            badge = APN::Notification.where("user_id_to = ? and `read` != 1", review.user_id).count(:id)
            user_to_array.push({:user_id => review.user_id, :badge => badge})
            
          end
        elsif notification_type == 'comment_on_comment'
          Comment.select([:user_id, :review_id]).where(:review_id => review.id).group(:user_id).each do |c|

              if c.user_id != c.review.user_id && c.user_id.to_i != user_id_from
                badge = APN::Notification.where("user_id_to = ? and `read` != 1", c.user_id).count(:id)
                user_to_array.push({:user_id => c.user_id, :badge => badge})
              end     

          end
        elsif notification_type == 'tagged' && !review.friends.blank?
          review.friends.split(',').each do |t|  
            if user = User.find_by_id(t)

              badge = APN::Notification.where("user_id_to = ? and `read` != 1", t).count(:id)
              user_to_array.push({:user_id => t, :badge => badge}) if t.to_i != user_id_from

            end
          end
        elsif notification_type == 'tagged_by_friend'
          if review.user_id != user_id_from
        
            review.friends.split(',').each do |t|
              if tagged = User.find_by_id(t)
                
                Follower.select(:user_id).where(:follow_user_id => tagged.id).each do |f|
                  if user = User.find_by_id(f.user_id)

                    badge = APN::Notification.where("user_id_to = ? and `read` != 1", f.user_id).count(:id)
                    user_to_array.push({:user_id => f.user_id, :badge => badge}) if f.user_id.to_i != user_id_from
                  end
                end 
                alert = restaurant_name.nil? ? "Tagged your friend #{t.name} in dish-in" : "Tagged your friend #{t.name} at #{restaurant_name}"

              end
            end 
            
          end
        end
        
        alert = case notification_type
                when 'like' then "Liked your dish-in in #{dish_name} "
                when 'comment' then "Commented on your dish-in in #{dish_name} "
                when 'comment_on_comment' then "Also commented on #{dish_name}"
                when 'dishin' then "Dished in #{dish_name}"
                when 'tagged' then restaurant_name.nil? ? "Tagged you in dish-in #{dish_name}" : "Tagged you at #{restaurant_name}"
                end
      
      elsif notification_type == 'following' && user_id_to && user_id_from != user_id_to 
              alert = "Started following you"

              badge = APN::Notification.where("user_id_to = ? AND `read` != 1", user_id_to).count(:id)
              user_to_array.push({:user_id => user_id_to, :badge => badge})

      elsif notification_type == 'fb_friend' && user_id_to && user_id_from != user_id_to
   
              alert = "Your friend from facebook has joined Dish.fm"
              badge = APN::Notification.where("user_id_to = ? and `read` != 1", user_id_to).count(:id)
              user_to_array.push({:user_id => user_id_to, :badge => badge})
  
      end

      if user_to_array.count > 0
        send = 0
        
        user_to_array.each do |u|
            
            pref = UserPreference.find_by_user_id(u[:user_id])
            push_allow = 1
            email_allow = 1
            
            if notification_type == 'like'
              push_allow = 0 if pref.like_mobile == false
              email_allow = 0 if pref.like_email == false
            elsif notification_type == 'comment' || notification_type == 'comment_on_comment'
              push_allow = 0 if pref.comment_mobile == false
              email_allow = 0 if pref.comment_email == false
            elsif notification_type == 'dishin'
              push_allow = 0 if pref.dishin_mobile == false
              email_allow = 0 if pref.dishin_email == false
            elsif notification_type == 'tagged' || notification_type == 'tagged_by_friend'
              push_allow = 0 if pref.tagged_mobile == false
              email_allow = 0 if pref.tagged_email == false
            elsif notification_type == 'following'
              push_allow = 0 if pref.following_mobile == false
              email_allow = 0 if pref.following_email == false  
            elsif notification_type == 'fb_friend'
              push_allow = 0 if pref.fb_friend_mobile == false
              email_allow = 0 if pref.fb_friend_email == false                                                    
            end

            APN::Device.where(:user_id => u[:user_id]).each do |device|
              notification = APN::Notification.new
              notification.device = device
              notification.badge = u[:badge] + 1  
              notification.sound = 'default'   
              notification.alert = alert
              notification.notification_type = notification_type
              notification.review_id = review ? review.id : 0
              notification.user_id_from = user_id_from
              notification.user_id_to = u[:user_id]
              notification.push_allow = push_allow
              notification.email_allow = email_allow
              notification.sent_at = Time.now.to_s(:db) if push_allow == 0
              notification.mailed_at = Time.now.to_s(:db) if email_allow == 0              
              notification.save
              send = 1
            end
      
        end
  
        if send == 1
          system "rake apn:notifications:deliver RAILS_ENV=production &"
          # system "rake email:notifications:deliver &"
        end
      
      end
      
    end
    
  end
end
