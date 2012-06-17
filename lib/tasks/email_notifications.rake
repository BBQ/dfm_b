# encoding: utf-8
namespace :email do
  namespace :notifications do
    
    desc "Email all unmailed APN notifications."
    task :deliver => [:environment] do
      
      APN::Notification.where("mailed_at IS NULL").group('review_id, user_id_to, notification_type, user_id_from').each do |n|
        if to_user = User.find_by_id(n.user_id_to)
          if email = to_user.email

            message = "#{User.find_by_id(n.user_id_from).name.split(' ')[0]} #{n.alert.downcase}"
            mail = UserMailer.email_notification(to_user, message).deliver
          
          end
        end
      end
      APN::Notification.where("mailed_at IS NULL").each { |n| n.update_attributes(:mailed_at => Time.now)}
      
    end
    
  end
end