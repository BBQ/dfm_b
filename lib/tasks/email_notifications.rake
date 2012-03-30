# encoding: utf-8
namespace :email do
  namespace :notifications do
    
    desc "Email all unmailed APN notifications."
    task :deliver => [:environment] do
      p UserMailer.email_notification.deliver
    end
    
  end # notifications
end # email