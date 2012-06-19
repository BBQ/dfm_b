# encoding: utf-8
namespace :email do
  namespace :notifications do
    
    desc "Email all unmailed APN notifications."
    task :deliver => [:environment] do
      
      APN::Notification.where("mailed_at IS NULL").group('review_id, user_id_to, notification_type, user_id_from').each do |n|
        if to_user = User.find_by_id(n.user_id_to)
          if email = to_user.email

            message = "#{User.find_by_id(n.user_id_from).name.split(' ')[0]} #{n.alert.downcase}"
            if mail = UserMailer.email_notification(to_user, message).deliver
              APN::Notification.update_all ["mailed_at = '#{Time.now}'"], ["review_id = ? AND user_id_to = ? AND notification_type = ? AND user_id_from  = ?", n.review_id, n.user_id_to, n.notification_type, n.user_id_from]          
            end
            
          end
        end
      end
      
    end
    
  end
end