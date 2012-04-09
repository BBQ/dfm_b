# encoding: utf-8
class Comment < ActiveRecord::Base
  belongs_to :review
  belongs_to :user
  
  default_scope order('id DESC')
  
  def self.add(data, self_review)
    unless self_review.blank?
      if dish = Dish.find_by_id(data[:review_id])
        unless dish.photo.blank?
          DishComment.create({:user_id => data[:user_id], :dish_id => data[:review_id], :text => data[:text]})
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
      dish_name = case review.rtype
        when 'home_cooked' then review.home_cook.name
        when 'delivery' then review.dish_delivery.name
        else review.dish.name
      end
      Notification.send(data[:user_id], 'comment', review.user_id, dish_name, nil, nil, review.id)
      Notification.send(data[:user_id], 'comment_on_comment', review.user_id, dish_name, nil, nil, review.id)
      
      system "rake facebook:comment COMMENT_ID='#{с.id}' &"
      system "rake twitter:comment COMMENT_ID='#{с.id}' &"
      
    end  
  end

  def delete
    if comment = Comment.find_by_id(id)
      comment.review.count_comments -= 1 
      comment.review.save
      
      if nc = APN::Notification.find_by_user_id_from_and_review_id_and_notification_type(comment.user_id,comment.review_id,'comment')
        nc.destroy
      end
      
      if ncc = APN::Notification.find_by_user_id_from_and_review_id_and_notification_type(comment.user_id,comment.review_id,'comment_on_comment')
        ncc.destroy
      end
      
      comment.destroy
      1
    else
      0
    end
  end
end
