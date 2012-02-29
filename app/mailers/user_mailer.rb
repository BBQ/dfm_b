class UserMailer < ActionMailer::Base
  
  default :from => "Dish.fm <hi@dish.fm>"
   
  def email_notification
    @url  = "http://test.dish.fm"
    subject = "Dish.fm Notifications"
    
    ApnNotification.where("emailed_at IS NULL").each do |n|
      @user = n.devise.user.name
      mail(:to => n.devise.user.email, :subject => subject)
      @text = n.alert
      n.emailed_at = Time.now
      n.save
    end
    
  end
  
end