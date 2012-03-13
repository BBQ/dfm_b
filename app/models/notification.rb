class Notification < ActiveRecord::Base
  
  def self.send_push(from_user_id, data, type)
    
    if user = User.select(:name).find_by_id(from_user_id)  
      
      if (type == 'like' || type == 'comment') && user.id != data.user.id 
        if device = APN::Device.where(:user_id => data.user.id).first
          dish_name = data.home_cooked == true ? data.home_cook.name : data.dish.name
          alert = "#{user.name.split.first} #{user.name.split.second[0]}. #{type} your review #{dish_name}"
          badge = Like.where("user_id = ? and `read` != 1", data.user.id).count(:id)
          badge += Comment.where("user_id = ? and `read` != 1", data.user.id).count(:id)
          badge += Follower.where("user_id = ? and `read` != 1", data.user.id).count(:id)
        end
      elsif type == 'comment_on_comment' && user.id != data.user.id 
        Comment.select(:user_id).where(:review_id => data.review_id).each do |c|
          if device = APN::Device.where(:user_id => c.user_id).first
            dish_name = data.home_cooked == true ? data.home_cook.name : data.dish.name
            alert = "#{user.name.split.first} #{user.name.split.second[0]}. #{type} also commented on #{dish_name}"
            badge = Like.where("user_id = ? and `read` != 1", data.user.id).count(:id)
            badge += Comment.where("user_id = ? and `read` != 1", data.user.id).count(:id)
            badge += Follower.where("user_id = ? and `read` != 1", data.user.id).count(:id)
          end
        end
      elsif type == 'dishin'
        Follower.select(:user_id).where(:follow_user_id => from_user_id).each do |f|
          if device = APN::Device.where(:user_id => f.user_id).first
            dish_name = data.home_cooked == true ? data.home_cook.name : data.dish.name
            alert = "#{user.name.split.first} #{user.name.split.second[0]}. dished in #{dish_name}"
            badge = Like.where("user_id = ? and `read` != 1", data.user.id).count(:id)
            badge += Comment.where("user_id = ? and `read` != 1", data.user.id).count(:id)
            badge += Follower.where("user_id = ? and `read` != 1", data.user.id).count(:id)
          end
        end          
      elsif type == 'following' && user.id != data 
        if device = APN::Device.where(:user_id => data).first
          alert = "#{user.name.split.first} #{user.name.split.second[0]}. started #{type} you"
          badge = Like.where("user_id = ? and `read` != 1", data).count(:id)
          badge += Comment.where("user_id = ? and `read` != 1", data).count(:id)
          badge += Follower.where("user_id = ? and `read` != 1", data).count(:id)
        end
      elsif type == 'tagged' && user.id != data.user_id
        data.friends.split(',').each do |t|
          if device = APN::Device.where(:user_id => t).first
            alert = "tagged you at #{data.restaurant.name}"
            badge = Like.where("user_id = ? and `read` != 1", data).count(:id)
            badge += Comment.where("user_id = ? and `read` != 1", data).count(:id)
            badge += Follower.where("user_id = ? and `read` != 1", data).count(:id)
          end
        end
      elsif type == 'tagged_by_friend' && user.id != data.user_id
        data.friends.split(',').each do |t|
          if tagged = User.find_by_id(t)
            Follower.select(:user_id).where(:follow_user_id => tagged.id).each do |f|
              if device = APN::Device.where(:user_id => f.user_id).first
                alert = "tagged your friend at #{data.restaurant.name}"
                badge = Like.where("user_id = ? and `read` != 1", data).count(:id)
                badge += Comment.where("user_id = ? and `read` != 1", data).count(:id)
                badge += Follower.where("user_id = ? and `read` != 1", data).count(:id)
              end
            end
          end
        end      
      elsif type == 'new_fb_user' && user.id != data 
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
