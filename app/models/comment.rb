class Comment < ActiveRecord::Base
  belongs_to :feedback
  belongs_to :user
  
  default_scope order('id DESC')
  
  def add(data)
    comment_id = Comment.create(data)
    review = Review.find_by_id(data[:review_id])
    review.count_comments += 1
    review.save
    
    # Send email
    hours_7 = Notification.where("user_id = ? AND created_at >= ADDDATE(NOW(), INTERVAL - 7 HOUR)", review.user.id)
    if hours_7.blank?
      UserMailer.notification_email(data[:user_id], review, 'comment').deliver
    end
    
  end

  def delete(user_id, comment_id)
    comment = Comment.find(comment_id)
    feedback_id = comment.feedback.id
    if comment.user.id = user_id
      comment.destroy
      Feedback.find(feedback_id)
    end
  end
end
