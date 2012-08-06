# encoding: utf-8
namespace :apn do
  
  namespace :notifications do
    
    desc "Deliver all unsent APN notifications."
    task :deliver => [:environment] do
      begin
        APN::Notification.send_notifications
      rescue
        APN::Notification.where('sent_at IS NULL').order('id DESC').limit(1).delete
      end
    end
    
  end # notifications
  
  namespace :feedback do
    
    desc "Process all devices that have feedback from APN."
    task :process => [:environment] do
      APN::Feedback.process_devices
    end
    
  end
  
end # apn