class Notification < ActiveRecord::Base
  
  def self.send_push(from_user_id, data, type)
    
    if user = User.select(:name).find_by_id(from_user_id)  
      
      if type == 'like' || type == 'comment'
        if device = APN::Device.where(:user_id => data.user.id).first   
          alert = "#{user.name.split.first} #{user.name.split.second[0]}. #{type} your review #{data.dish.name}"
        end
      elsif type == 'following'
        if device = APN::Device.where(:user_id => data).first  
          alert = "#{user.name.split.first} #{user.name.split.second[0]}. started #{type} you"
        end
      end

      if device
        alert = "#{alert.slice 0 .. 40}..." if alert.length > 40
        notification = APN::Notification.new   
        notification.device = device   
        notification.badge = 1   
        notification.sound = true   
        notification.alert = alert    
        notification.save
        system "rake apn:notifications:deliver &"
      end
      
    end
  end
  
end
