class UserMailer < ActionMailer::Base
  
  default :from => "Dish.fm <hi@dish.fm>"
   
  def email_notification
    @url  = "http://test.dish.fm"
    subject = "Dish.fm Notifications"
    
    APN::Notification.where("mailed_at IS NULL").each do |n|
      user = User.find_by_id(n.user_id_to)
      @user = user.name
      mail(:to => user.email, :subject => subject)
      @text = n.alert
      n.mailed_at = Time.now
      n.save
    end
    
  end
  
end