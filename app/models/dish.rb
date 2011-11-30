class Dish < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
  belongs_to :network
  has_many :reviews
  
  mount_uploader :photo, ImageUploader
  
  def find_image
    
    if photo.blank?
      review = Review.where("dish_id = ?", id).order('count_likes DESC').first.photo
    else
      photo
    end
    
  end
  
  def self.api_get_dish(user_id, dish_id)
    
    dish = Dish.find_by_id(dish_id)
    user_review = Review.find_by_dish_id_and_user_id(dish.id,user_id) if user_id
    position_in_network = Dish.where("rating/votes >= ? AND network_id = ?", "#{dish.rating/dish.votes}", dish.network_id).order("rating/votes DESC, votes DESC").count
    position_in_type = Dish.where("rating/votes >= ? AND dish_type_id = ?", "#{dish.rating/dish.votes}", dish.dish_type_id).order("rating/votes DESC, votes DESC").count
    subtype = DishSubtype.find_by_id(dish.dish_subtype_id)
    
    top_expert_id = (Review.where('dish_id = ?', dish.id).group('user_id').count).max[0]
    top_expert = User.find_by_id(top_expert_id)
    
    reviews = []
    dish.reviews.each do |review|
      reviews.push({
        :image_sd => review.photo.iphone.url != '/images/noimage.jpg' ? review.photo.iphone.url : nil ,
        :image_hd => review.photo.iphone_retina.url != '/images/noimage.jpg' ? review.photo.iphone_retina.url : nil,
        :user_name => review.user.name,
        :user_avatar => "http://graph.facebook.com/#{review.user.facebook_id}/picture?type=square",
        :text => review.text,
        :rating => review.rating
      })
    end
    
    restaurants = []
    dish.network.restaurants.each do |restaurant|
      restaurants.push({
        :name => restaurant.name,
        :address => restaurant.address,
        :phone => restaurant.phone,
        :working_hours => restaurant.time,
        :lat => restaurant.lat,
        :lon => restaurant.lon,
        :description => restaurant.description
      })
    end
    
    data = {
      :current_user_rating => user_review ? user_review.rating : nil,
      :photo => dish.find_image.square.url != '/images/noimage.jpg' ? dish.find_image.square.url : nil ,
      :rating => dish.rating,
      :votes => dish.votes,
      :position_in_network => position_in_network,
      :position_in_type => position_in_type,
      :type_name => dish.dish_type.name,
      :subtype_name => dish.dish_subtype ? dish.dish_subtype.name : nil,
      :reviews => reviews,
      :top_expert => {
        :user_name => top_expert.name,
        :user_avatar => "http://graph.facebook.com/#{top_expert.facebook_id}/picture?type=square",
        :user_id => top_expert.id
      },
      :restaurants => restaurants
      
    }
    data.as_json
  end
  
end
