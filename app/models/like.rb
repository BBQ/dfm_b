class Like < ActiveRecord::Base
  
  belongs_to :review
  belongs_to :user
  
  def unlike?(user_id, review_id)
    Like.find_by_user_id_and_review_id(user_id, review_id)
  end
  
  def save_me(user_id, review_id)
    if review = Review.find_by_id(review_id)
      if unlike = unlike?(user_id, review_id)
        review.count_likes -= 1 
        review.save
        unlike.delete
      else
        review.count_likes += 1 
        review.save
        like_id = review.likes.create({:user_id => user_id, :review_id => review_id}).id
        hours_7 = Notification.where('user_id =? AND like_id = ? AND created_at >= current_time()-7', review.user.id, like_id)          
        if hours_7.blank?
          if UserMailer.notification_email(user_id, review, 'review').deliver
            Notification.create({:user_id =>review.user.id, :like_id => like_id})
          end
        end
      end
    else
      error = 'review not found'
    end
    data = {:error => error, :result => review}
  end
  
end
