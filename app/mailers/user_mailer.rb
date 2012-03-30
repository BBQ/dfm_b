class UserMailer < ActionMailer::Base
  
  default :from => "Dish.fm <hi@dish.fm>"
   
  def email_notification
    @url  = "http://test.dish.fm"
    subject = "Dish.fm Notifications"
    
    APN::Notification.where("mailed_at IS NULL").each do |n|
      if user = User.find_by_id(n.user_id_to)

        if email = user.email
          @user = user.name
          @text = n.alert
          
          mail(:to => email, :subject => subject)
          
          n.mailed_at = Time.now
          n.save
        end
        
      end
    end
  end
  
end