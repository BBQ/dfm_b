class Notification < ActiveRecord::Base
  
  def send_review_like_push(from_user_id, review)
    
    if device = APN::Device.where(:user_id => review.user.id).first  
      if user = User.select(:name).find_by_id(from_user_id)  
        notification = APN::Notification.new   
        notification.device = device   
        notification.badge = 1   
        notification.sound = true   
        notification.alert = "User #{user.name} like your review on dish #{review.dish.name}"   
        notification.save
        system "rake apn:notifications:deliver &"
      end
    end  
    
  end
  
end
