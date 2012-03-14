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
        Comment.create(data)
        review.count_comments += 1
        review.save
      end

      # Send notifications
      Notification.send(data[:user_id], 'comment', review.user_id, review.dish.name, nil, nil, review.id)
      Notification.send(data[:user_id], 'comment_on_comment', review.user_id, review.dish.name, nil, nil, review.id)
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
