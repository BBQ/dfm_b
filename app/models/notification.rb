class Notification < ActiveRecord::Base
  
  def self.send(user_id_from, notification_type, user_id_to = nil, dish_name = nil, restaurant_name = nil, friends = nil, review_id = nil)
    
    user_id_from = user_id_from.to_i
    user_id_to = user_id_to.to_i
    review_id = review_id.to_i
    if user = User.select(:name).find_by_id(user_id_from) && notification_type
      user_ids_to_array = []
      
      if (notification_type == 'like' || notification_type == 'comment') && (user_id_from != user_id_to) && dish_name && review_id
        
              if notification_type == 'like'
                alert = "Liked your dish-in in #{dish_name} "
              elsif notification_type == 'comment'
                alert = "Commented on your dish-in in #{dish_name} "
              end
                
              badge = APN::Notification.where("user_id_to = ? and `read` != 1", user_id_to).count(:id)
              user_ids_to_array.push({:user_id => user_id_to, :badge => badge})
              
      elsif notification_type == 'comment_on_comment' && user_id_to && review_id 
              alert = "Also commented on #{dish_name}"              
              
              Comment.select([:user_id, :review_id]).where(:review_id => review_id).group(:user_id).each do |c|
                  if c.user_id != c.review.user_id
                    badge = APN::Notification.where("user_id_to = ? and `read` != 1", c.user_id).count(:id)
                    user_ids_to_array.push({:user_id => c.user_id, :badge => badge}) if c.user_id.to_i != user_id_from
                  end               
              end
              
      elsif notification_type == 'dishin' && dish_name
              alert = "Dished in #{dish_name}"        
                    
              Follower.select(:user_id).where(:follow_user_id => user_id_from).each do |f|
                  if user = User.find_by_id(f.user_id)
                    
                    badge = APN::Notification.where("user_id_to = ? and `read` != 1", f.user_id).count(:id)
                    user_ids_to_array.push({:user_id => f.user_id, :badge => badge}) if f.user_id.to_i != user_id_from
                    
                  end
                  
              end    
           
      elsif notification_type == 'following' && user_id_to && user_id_from != user_id_to 
        
              alert = "Started following you"
              badge = APN::Notification.where("user_id_to = ? AND `read` != 1", user_id_to).count(:id)
              
              user_ids_to_array.push({:user_id => user_id_to, :badge => badge})
              
      elsif notification_type == 'tagged' && friends && review_id
        
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
      elsif notification_type == 'tagged_by_friend' && restaurant_name && friends
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

      elsif notification_type == 'new_fb_user' && user_id_from != user_id_to
         
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
        
        system "rake apn:notifications:deliver &" if send == 1
        # system "rake email:notifications:deliver &"
      end
      
    end
  end
  
end
