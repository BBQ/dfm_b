class Notification < ActiveRecord::Base
  
  def self.send_push(from_user_id, review, type)
    
    if device = APN::Device.where(:user_id => review.user.id).first  
      if user = User.select(:name).find_by_id(from_user_id)  
        
        text = "#{type} your review" if type == 'like' || type = 'comment'
        text = "started #{type} you" if type == 'following'
        
        alert = "#{user.name.split.first} #{user.name.split.second[0]}. #{text} #{review.dish.name}"
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
