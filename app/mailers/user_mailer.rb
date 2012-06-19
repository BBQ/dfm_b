class UserMailer < ActionMailer::Base
  
  default :from => "Dish.FM <hello@mail.dish.fm>"
  
  def feedback(data)
    mail_to = 'hello@dish.fm'
    subject = "Feedback message from website"
    @email_from = "#{data[:name]} (#{data[:email]})"
    @text = data[:body]    
    mail(:to => mail_to, :subject => subject)
  end
  
   
  def email_notification(to_user, message)
    subject = "Dish.fm Notifications"
    @url  = "http://dish.fm"
    
    @user = "#{to_user.name.split.first} #{to_user.name.split.second[0] if to_user.name.split.second}"
    @text = message
    mail(:to => to_user.email, :subject => subject)
  end
  
  def email_password_recover(user)
    @url  = "http://dish.fm"
    subject = "Dish.fm Password Recovery"

    @user = "#{user.name.split.first} #{user.name.split.second[0] if user.name.split.second}"
    @text = "To recover your password follow this link: #{@url}/users/recover/#{user.crypted_password}"
    mail(:to => user.email, :subject => subject)
  end
  
end