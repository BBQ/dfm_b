class UserMailer < ActionMailer::Base
  
  default :from => "Dish.FM <hello@mail.dish.fm>"
  
  def feedback(data)
    mail_to = 'a.surin@dish.fm'
    subject = "Feedback message from website"
    @email_from = "#{data[:name]} #{data[:email]}"
    @text = data[:body]    
    mail(:to => mail_to, :subject => subject)
  end
  
   
  def email_notification
    @url  = "http://test.dish.fm"
    subject = "Dish.fm Notifications"
    
    APN::Notification.where("mailed_at IS NULL").each do |n|
      if user_to = User.find_by_id(n.user_id_to)

        if email = user_to.email
          @user = user_to.name
          @text = "#{User.find_by_id(n.user_id_from).name.split(' ')[0]} #{n.alert.downcase}"
          mail(:to => email, :subject => subject)
          
          n.mailed_at = Time.now
          n.save
        end
        
      end
    end
  end
  
  def email_password_recover(user)
    @url  = "http://test.dish.fm"
    subject = "Dish.fm Password Recovery"

    @user = user.name
    @text = "To recover your password follow this link: #{@url}/users/recover/#{user.crypted_password}"

    mail(:to => user.email, :subject => subject)
  end
  
end