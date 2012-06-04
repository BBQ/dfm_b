class StaticController < ApplicationController
  def fb_redirect
    
  end
  
  def terms
    
  end

  def privacy
    
  end
  
  def support
    if params && (params[:name] || params[:email] || params[:body])
      if !params[:name].blank? && !params[:email].blank? && !params[:body].blank?
        data = {
          :name => params[:name],
          :email => params[:email],
          :body => params[:body]
        }
        if UserMailer.feedback(data).deliver
          @message = "Thank You! Your message was successfully sent! We will answer You ASAP!"
        end
      else
        @message = "Please fill in all fields!"
      end
    end
    
  end
  
  def about
    
  end

end
