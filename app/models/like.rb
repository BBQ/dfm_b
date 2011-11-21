class Like < ActiveRecord::Base
  
  belongs_to :review
  belongs_to :user
  
  def unlike?(user_id, review_id)
    unlike = Like.find_by_user_id_and_review_id(user_id, review_id)
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
        review.likes.create({:user_id => user_id, :review_id => review_id})
      end
    else
      error = 'review not found'
    end
    data = {:error => error, :result => review}
  end
  
end
