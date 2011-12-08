class UserMailer < ActionMailer::Base
  default :from => "Dish.fm <hi@dish.fm>"
   
  def notification_email(who, review, type)
    
    @user = User.find_by_id(who)
    @url  = "http://test.dish.fm"
    
    if type == 'like' || type == 'comment' 
      last_like_id = Notification.find_last_by_user_id(review.user_id, :conditions => "like_id IS NOT NULL") ? Notification.find_last_by_user_id(review.user_id, :conditions => "like_id IS NOT NULL").like_id : 0
      last_comment_id = Notification.find_last_by_user_id(review.user_id, :conditions => "comment_id IS NOT NULL") ? Notification.find_last_by_user_id(review.user_id, :conditions => "comment_id IS NOT NULL").comment_id : 0
      
      @likes_review = Review.where("reviews.user_id = ?", review.user_id).includes(:likes).where("likes.id > ? AND likes.user_id != ?", last_like_id, review.user_id)
      @comments_review = Review.where("reviews.user_id = ?", review.user_id).includes(:comments).where("comments.id > ? AND comments.user_id != ?", last_comment_id, review.user_id)

      count_l = 0
      count_c = 0
      
      @likes_review.each do |r| 
        r.likes.each {count_l += 1}
        @like_id = r.likes.last.id
      end
      
      @comments_review.each do |r| 
        r.comments.each {count_c += 1}
        @comment_id = r.comments.last.id
      end
      
      likes = " #{count_l} new like(s)" if count_l > 0
      comments = " #{count_c} new comment(s)" if count_c > 0
      
      subject = "You have" + (likes ||= '') + (!count_l.nil? && count_c.nil? ? ' and' : '') + (comments ||= '') + " on Dish.fm"
    end    
    
    # if type == 'follow'
    #   subject = @user.name + ' is now following you on Dish.fm'
    # end
    
    if @likes_review.count > 0 || @comments_review.count > 0
      mail(:to => review.user.email, :subject => subject)
      
      user_id = @likes_review.count > 0 ? @likes_review.first.user_id : @comments_review.first.user_id
      Notification.create({:user_id => user_id, :like_id => @like_id, :comment_id => @comment_id})
    end
    
  end
end