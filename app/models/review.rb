class Review < ActiveRecord::Base
  belongs_to :dish
  belongs_to :restaurant
  belongs_to :network
  belongs_to :user
  
  has_many :comments
  has_many :likes
  
  default_scope order('reviews.id DESC')
  
  mount_uploader :photo, ImageUploader 
  
  def as_json(options={})
    self.restaurant.rating = self.network.rating if restaurant && network
    self.restaurant.votes = self.network.votes if restaurant && network
    self.restaurant.photo = self.restaurant.photo.iphone.url if restaurant && restaurant.photo
        
    super(:only => [:user_id, :text, :count_likes, :created_at], 
          :include => { 
            :dish => {:only => [:id, :name, :photo, :rating, :votes]},
            :restaurant => {:only => [:id, :name, :photo, :address, :rating, :votes]},
            :likes => {:include => {:user => { :only => [:name]}}},
            :comments => {:only => [:text, :created_at], :include => {:user => { :only => [:name, :facebook_id]}}}
          })
  end
  
  def format_review_for_api(user_id)
    data = {
      :review_id => id,
      :created_at => created_at.to_time.to_i,
      :text => text,
      :dish_id => dish.id,
      :dish_name => dish.name,
      :restaurant_id => restaurant.id,    
      :restaurant_name => restaurant.name,
      :user_name => user.name,
      :user_facebook_id => user.facebook_id,
      :likes => count_likes,
      :comments => count_comments,
      :review_rating => rating,
      :dish_rating => dish.rating,
      :image_sd => photo.iphone.url != '/images/noimage.jpg' ? photo.iphone.url : '' ,
      :image_hd => photo.iphone_retina.url != '/images/noimage.jpg' ? photo.iphone_retina.url : '',
      :liked => user_id && Like.find_by_user_id_and_review_id(user_id, id) ? 1 : 0
    }
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
        dish.rating = (dish.rating * dish.votes - fb.rating) / (dish.votes - 1)
        dish.rating = (dish.rating * (dish.votes - 1) + rating) / dish.votes
        dish.save
        if restaurant
          restaurant.rating = (restaurant.rating * restaurant.votes - fb.rating) / (restaurant.votes - 1)
          restaurant.rating = (restaurant.rating * (restaurant.votes - 1) + rating) / restaurant.votes
          restaurant.save
        end
        network.rating = (network.rating * network.votes - fb.rating) / (network.votes - 1)
        network.rating = (network.rating * (network.votes - 1) + rating) / network.votes
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
          dish.rating = (dish.rating * dish.votes + rating) / (dish.votes + 1)
          dish.votes += 1
          dish.save
          if restaurant
            restaurant.rating = (restaurant.rating * restaurant.votes + rating) / (restaurant.votes + 1)
            restaurant.votes += 1
            restaurant.save
          end
          network.rating = (network.rating * network.votes + rating) / (network.votes + 1)
          network.votes += 1
          network.save
      end
      status = 'created'
    end
    {:status => 'updated', :dish => dish}
  end 

end
