class Notification < ActiveRecord::Base
  
  def self.send(user_id_from, notification_type, user_id_to = nil, dish_name = nil, restaurant_name = nil, friends = nil, review_id = nil)
    
    if user = User.select(:name).find_by_id(user_id_from) && notification_type
      
      user_ids_to_array = []
      if (notification_type == 'like' || notification_type == 'comment') && (user_id_from != user_id_to) && dish_name && review_id
        
              alert = "#{notification_type} your review #{dish_name}"
              badge = APN::Notification.where("user_id_to = ? and `read` != 1", user_id_to).count(:id)
              
              user_ids_to_array.push({:user_id => user_id_to, :badge => badge})
              
      elsif notification_type == 'comment_on_comment' && user_id_to && review_id && user_id_from != user_id_to 
                            
              alert = "also commented on #{dish_name}"              
              Comment.select(:user_id).where(:review_id => review_id).each do |c|
               
                    badge = APN::Notification.where("user_id_to = ? and `read` != 1", c.user_id).count(:id)
                    user_ids_to_array.push({:user_id => c.user_id, :badge => badge})
                                    
              end
              
      elsif notification_type == 'dishin' && dish_name
        
              alert = "dished in #{dish_name}"              
              Follower.select(:user_id).where(:follow_user_id => user_id_from).each do |f|
            
                  if user = User.find_by_id(f.user_id)
                    badge = APN::Notification.where("user_id_to = ? and `read` != 1", f.user_id).count(:id)
                    user_ids_to_array.push({:user_id => f.user_id, :badge => badge})
                  end
                  
              end    
           
      elsif notification_type == 'following' && user_id_to && user_id_from != user_id_to 
        
              alert = "started following you"
              badge = APN::Notification.where("user_id_to = ? AND `read` != 1", user_id_to).count(:id)
              
              user_ids_to_array.push({:user_id => user_id_to, :badge => badge})
              
      elsif notification_type == 'tagged' && restaurant_name && friends
        
              alert = "tagged you at #{restaurant_name}"
              friends.split(',').each do |t|
                
                  if user = User.find_by_id(t)
                    badge = APN::Notification.where("user_id_to = ? and `read` != 1", t).count(:id)
                    user_ids_to_array.push({:user_id => t, :badge => badge})
                  end
                
              end
        
      elsif notification_type == 'tagged_by_friend' && restaurant_name && friends

              friends.split(',').each do |t|
                
                  if tagged = User.find_by_id(t)
              
                      alert = "tagged your friend at #{restaurant_name}"
                      Follower.select(:user_id).where(:follow_user_id => tagged.id).each do |f|
              
                          if user = User.find_by_id(f)
                
                            badge = APN::Notification.where("user_id_to = ? and `read` != 1", f).count(:id)
                            user_ids_to_array.push({:user_id => f, :badge => badge})
                            
                          end
                      end                  
                  end
              end  

      elsif notification_type == 'new_fb_user' && user_id_from != user_id_to
         
              alert = "(your friend from facebook) has joined Dish.fm"
              badge = APN::Notification.where("user_id_to = ? and `read` != 1", user_id_to).count(:id)
              user_ids_to_array.push({:user_id => user_id_to, :badge => badge})
        
      end

      if user_ids_to_array.count > 0
        user_ids_to_array.each do |u|

            notification = APN::Notification.new
            notification.device = APN::Device.find_by_user_id(u[:user_id]) ||= 0
            notification.badge = u[:badge].to_i + 1   
            notification.sound = true   
            notification.alert = alert
            notification.notification_type = notification_type
            notification.review_id = review_id ? review_id : 0
            notification.user_id_from = user_id_from
            notification.user_id_to = u[:user_id]
            notification.read = 0
            notification.save
            
        end
        
        system "rake apn:notifications:deliver &" if device
        system "rake email:notifications:deliver &"
      end
      
    end
  end
  
end
