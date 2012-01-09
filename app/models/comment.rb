class Comment < ActiveRecord::Base
  belongs_to :review
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

  def delete
    if comment = Comment.find_by_id(id)
      comment.review.count_comments -= 1 
      comment.review.save
      comment.destroy
      1
    else
      0
    end
  end
end
