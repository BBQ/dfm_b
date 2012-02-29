# encoding: utf-8
namespace :email do
  
  namespace :notifications do
    
    desc "Email all unmailed APN notifications."
    task :deliver => [:environment] do
      UserMailer.email_notification
    end
    
  end # notifications
  
end # email