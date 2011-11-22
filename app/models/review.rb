class Review < ActiveRecord::Base
  belongs_to :dish
  belongs_to :restaurant
  belongs_to :network
  belongs_to :user
  
  has_many :comments
  has_many :likes
  
  default_scope order('id DESC')
  
  mount_uploader :photo, ImageUploader 
  
  def as_json(options={})
    self.restaurant.rating = self.network.rating
    self.restaurant.votes = self.network.votes
    self.restaurant.photo = self.restaurant.photo.iphone.url
        
    super(:only => [:text, :count_likes, :created_at], 
          :include => { 
            :dish => {:only => [:name, :photo, :rating, :votes]},
            :restaurant => {:only => [:name, :photo, :rating, :votes]},
            :likes => {:include => {:user => { :only => [:name]}}},
            :comments => {:only => [:text, :created_at], :include => {:user => { :only => [:name, :facebook_id]}}}
          })
  end
  
  def photo_iphone
    dish.photo.iphone.url
  end
  
  def review_exist?(user_id, dish_id)
    if fb = Review.where('user_id = ? && dish_id = ? && web = 1', user_id, dish_id).first
      fb
    end
  end  
  
  def save_review(user_review)
   
    rating = user_review[:rating].to_i
    dish = Dish.find(user_review[:dish_id])
    restaurant = Restaurant.find_by_id(user_review[:restaurant_id])
    network = Network.find_by_id(restaurant.network_id)
  
    if fb = review_exist?(user_review[:user_id], user_review[:dish_id])
      if rating > 0
        dish.rating -= fb.rating
        dish.rating += rating
        dish.save
        if restaurant
          restaurant.rating -= fb.rating
          restaurant.rating += rating
          restaurant.save
        end
        network.rating -= fb.rating
        network.rating += rating
        network.save
      end
      review = Review.find(fb.id)
      review.rating = rating if rating > 0
      review.comment = user_review[:comment] unless user_review[:comment].blank?
      review.save
      status = 'updated'
    else
      Review.create(user_review)  
      if rating > 0
          dish.rating += rating
          dish.votes += 1
          dish.save
          if restaurant
            restaurant.rating += rating
            restaurant.votes += 1
            restaurant.save
          end
          network.rating += rating
          network.votes += 1
          network.save
      end
      status = 'created'
    end
    {:status => 'updated', :dish => dish}
  end 
end
