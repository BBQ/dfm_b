# encoding: utf-8
namespace :push do
  
  task :send_to_all => :environment do
    # users = User.where("`current_city` LIKE '%Moscow%' OR `email` LIKE '%.ru%'")
    users = User.where("id = 149")
    users.each do |u|
      badge = APN::Notification.where("user_id_to = ? and `read` != 1", u.id).count(:id)
      
      APN::Device.where(:user_id => u.id).each do |device|
        notification = APN::Notification.new
        notification.device = device
        notification.badge = badge + 1  
        notification.sound = 'default'   
        notification.alert = 'Ура Пятница! ЕДА ждет тебя на Dish.fm!'
        notification.notification_type = 'following'
        notification.review_id = 0
        notification.user_id_from = 540
        notification.user_id_to = u.id
        notification.push_allow = 1
        notification.email_allow = 0
        notification.save
      end
      
    end
    system "rake apn:notifications:deliver RAILS_ENV=production &"
  end
  
end