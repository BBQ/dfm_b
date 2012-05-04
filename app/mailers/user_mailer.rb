class UserMailer < ActionMailer::Base
  
  default :from => 
   
  def email_notification
    @url  = "http://test.dish.fm"
    subject = "Dish.fm Notifications"
    from = "Dish.fm <hi@dish.fm>"
    
    APN::Notification.where("mailed_at IS NULL").each do |n|
      if user_to = User.find_by_id(n.user_id_to)

        if email = user_to.email
          @user = user_to.name
          @text = "#{User.find_by_id(n.user_id_from).name.split(' ')[0]} #{n.alert.downcase}"
          mail(:to => email, :subject => subject, :from => from)
          
          n.mailed_at = Time.now
          n.save
        end
        
      end
    end
  end
  
end