class UserMailer < ActionMailer::Base
  default :from => "Dish.fm <hi@dish.fm>"
   
  def notification_email(who, data, type)
    
    @user = User.find_by_id(who)
    @url  = "http://test.dish.fm"
    
    if type == 'review'
      @review = data
      subject = @user.name + ' liked your review on Dish.fm' 
    end

    if type == 'comment'    
      @review = data
      subject = @user.name + ' commented on your review on Dish.fm'
      @comment = Comment.find_by_user_id_and_review_id(data.user.id, data.id)
    end
    
    if type == 'follow'
      @follow = data
      subject = @user.name + ' is now following you on Dish.fm'
    end
    mail(:to => data.user.email, :subject => subject)
    
  end
end