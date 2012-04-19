# encoding: utf-8
class Comment < ActiveRecord::Base
  belongs_to :review
  belongs_to :user
  
  default_scope order('id DESC')
  
  def self.add(data, self_review)
    unless self_review.blank?
      if dish = Dish.find_by_id(data[:review_id])
        unless dish.photo.blank?
          c = DishComment.create({:user_id => data[:user_id], :dish_id => data[:review_id], :text => data[:text]})
          dish.count_comments += 1
          dish.save
        end
      end
    else
      if review = Review.find_by_id(data[:review_id])
        с = Comment.create(data)
        review.count_comments += 1
        review.save
      end

      # Send notifications
      Notification.send(data[:user_id], 'comment', nil, review)
      Notification.send(data[:user_id], 'comment_on_comment', nil, review)
      
      system "rake facebook:comment COMMENT_ID='#{с.id}' &"
      system "rake twitter:comment COMMENT_ID='#{с.id}' &"
    end  
    c ||= 0
  end

  def delete
    if comment = Comment.find_by_id(id)
      comment.review.count_comments -= 1 
      comment.review.save
      
      if nc = APN::Notification.find_by_user_id_from_and_review_id_and_notification_type(comment.user_id,comment.review_id,'comment')
        nc.destroy
      end
      
      if ncc_from = APN::Notification.find_by_user_id_from_and_review_id_and_notification_type(comment.user_id,comment.review_id,'comment_on_comment')
        ncc_from.destroy
      end
      
      if ncc_to = APN::Notification.find_by_user_id_to_and_review_id_and_notification_type(comment.user_id,comment.review_id,'comment_on_comment')
        ncc_to.destroy
      end
      
      comment.destroy
      1
    else
      0
    end
  end
end
