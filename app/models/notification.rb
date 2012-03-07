class Notification < ActiveRecord::Base
  
  def self.send_push(from_user_id, data, type)
    
    if user = User.select(:name).find_by_id(from_user_id)  
      
      if type == 'like' || type == 'comment'
        if device = APN::Device.where(:user_id => data.user.id).first   
          dish_name = data.home_cooked == true ? data.home_cook.name : data.dish.name
          alert = "#{user.name.split.first} #{user.name.split.second[0]}. #{type} your review #{dish_name}"
          badge = Like.where("user_id = ? and `read` != 1", data.user.id).count(:id)
          badge += Comment.where("user_id = ? and `read` != 1", data.user.id).count(:id)
          badge += Follower.where("user_id = ? and `read` != 1", data.user.id).count(:id)
        end
      elsif type == 'following'
        if device = APN::Device.where(:user_id => data).first  
          alert = "#{user.name.split.first} #{user.name.split.second[0]}. started #{type} you"
          badge = Like.where("user_id = ? and `read` != 1", data).count(:id)
          badge += Comment.where("user_id = ? and `read` != 1", data).count(:id)
          badge += Follower.where("user_id = ? and `read` != 1", data).count(:id)
        end
      elsif type == 'new_fb_user'
        if device = APN::Device.where(:user_id => data).first  
          alert = "Your facebook friend #{user.name.split.first} #{user.name.split.second[0]}. has joined Dish.fm"
          badge = Like.where("user_id = ? and `read` != 1", data).count(:id)
          badge += Comment.where("user_id = ? and `read` != 1", data).count(:id)
          badge += Follower.where("user_id = ? and `read` != 1", data).count(:id)
        end
      end

      if device
        alert = "#{alert.slice 0 .. 40}..." if alert.length > 40
        notification = APN::Notification.new   
        notification.device = device   
        notification.badge = badge.to_i + 1   
        notification.sound = true   
        notification.alert = alert    
        notification.save
        system "rake apn:notifications:deliver &"
        system "rake email:notifications:deliver &"
        
      end
      
    end
  end
  
end
