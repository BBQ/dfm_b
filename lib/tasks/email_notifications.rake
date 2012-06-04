# encoding: utf-8
namespace :email do
  namespace :notifications do
    
    desc "Email all unmailed APN notifications."
    task :deliver => [:environment] do
      
      APN::Notification.where("mailed_at IS NULL").each do |n|
        if to_user = User.find_by_id(n.user_id_to)
          if email = user_to.email
            text = "#{User.find_by_id(n.user_id_from).name.split(' ')[0]} #{n.alert.downcase}"
            p UserMailer.email_notification(to_user, message).deliver
          end
        end
      end
      
    end
    
  end
end