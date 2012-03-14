class Like < ActiveRecord::Base
  
  belongs_to :review
  belongs_to :user
  
  def self.save(user_id, review_id, self_review)
    unless self_review.blank?
      dish_id = review_id
      if dish = Dish.find_by_id(dish_id)
        unless dish.photo.blank?
          if like = DishLike.find_by_user_id_and_dish_id(user_id, dish_id)
            dish.count_likes -= 1 
            dish.save
            like.destroy
          else
            DishLike.create({:user_id => user_id, :dish_id => dish_id})
            dish.count_likes += 1 
            dish.save
          end
        end
      end
    else  
      if review = Review.find_by_id(review_id)
        if like = Like.find_by_user_id_and_review_id(user_id, review_id)
          review.count_likes -= 1 
          review.save
          like.destroy
        else
          Like.create({:user_id => user_id, :review_id => review_id})
          review.count_likes += 1 
          review.save

          # Send email
          dish_name = review.home_cooked == true ? review.home_cook.name : review.dish.name
          Notification.send(user_id, 'like', review.user_id, dish_name, nil, nil, review.id)          
        end
      end
    end
  end
  
end
