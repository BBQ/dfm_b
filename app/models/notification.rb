class Notification < ActiveRecord::Base
  
  def self.send_push(from_user_id, data, notification_type)
    
    if user = User.select(:name).find_by_id(from_user_id)  
      
      user_id_to = []
      if (notification_type == 'like' || notification_type == 'comment') && user.id != data.user.id 
        if device = APN::Device.where(:user_id => data.user.id).first
          dish_name = data.home_cooked == true ? data.home_cook.name : data.dish.name
          alert = "#{user.name.split.first} #{user.name.split.second[0]}. #{type} your review #{dish_name}"
          badge = APN::Notification.where("user_id_to = ? and `read` != 1", data.user.id).count(:id)
          user_id_to.push(data.user.id)
          review_id = data.id
        end
      elsif notification_type == 'comment_on_comment' && user.id != data.user.id 
        Comment.select(:user_id).where(:review_id => data.id).each do |c|
          if device = APN::Device.where(:user_id => c.user_id).first
            dish_name = data.home_cooked == true ? data.home_cook.name : data.dish.name
            alert = "#{user.name.split.first} #{user.name.split.second[0]}. also commented on #{dish_name}"
            badge = APN::Notification.where("user_id_to = ? and `read` != 1", data.user.id).count(:id)
            user_id_to.push(data.user.id)
            review_id = data.id
          end
        end
      elsif notification_type == 'dishin'
        Follower.select(:user_id).where(:follow_user_id => from_user_id).each do |f|
          if device = APN::Device.where(:user_id => f.user_id).first
            dish_name = data.home_cooked == true ? data.home_cook.name : data.dish.name
            alert = "#{user.name.split.first} #{user.name.split.second[0]}. dished in #{dish_name}"
            badge = APN::Notification.where("user_id_to = ? and `read` != 1", data.user.id).count(:id)
            user_id_to.push(data.user.id)
            review_id = data.id
          end
        end          
      elsif notification_type == 'following' && user.id != data 
        if device = APN::Device.where(:user_id => data).first
          alert = "#{user.name.split.first} #{user.name.split.second[0]}. started following you"
          badge = APN::Notification.where("user_id_to = ? and `read` != 1", data).count(:id)
          user_id_to.push(data)
        end
      elsif notification_type == 'tagged'
        data.friends.split(',').each do |t|
          if device = APN::Device.where(:user_id => t).first
            alert = "tagged you at #{data.restaurant.name}"
            badge = APN::Notification.where("user_id_to = ? and `read` != 1", data).count(:id)
            user_id_to.push(data)
          end
        end
      elsif notification_type == 'tagged_by_friend'
        data.friends.split(',').each do |t|
          if tagged = User.find_by_id(t)
            Follower.select(:user_id).where(:follow_user_id => tagged.id).each do |f|
              if device = APN::Device.where(:user_id => f.user_id).first
                alert = "tagged your friend at #{data.restaurant.name}"
                badge = APN::Notification.where("user_id_to = ? and `read` != 1", data).count(:id)
                user_id_to.push(data)
              end
            end
          end
        end      
      elsif notification_type == 'new_fb_user' && user.id != data 
        if device = APN::Device.where(:user_id => data).first
          alert = "Your facebook friend #{user.name.split.first} #{user.name.split.second[0]}. has joined Dish.fm"
          badge = APN::Notification.where("user_id_to = ? and `read` != 1", data).count(:id)
          user_id_to.push(data)
        end
      end

      if user_id_to.count > 0
        user_id_to.each do |u|
          if device = APN::Device.where(:user_id => u).first
            notification = APN::Notification.new
            notification.device = device   
            notification.badge = badge.to_i + 1   
            notification.sound = true   
            notification.alert = alert
            notification.notification_type = notification_type
            notification.review_id = review_id ? review_id : 0
            notification.user_id_from = from_user_id
            notification.user_id_to = user_id_to
            notification.save
          end
        end
        system "rake apn:notifications:deliver &"
        system "rake email:notifications:deliver &"
      end
      
    end
  end
  
end
