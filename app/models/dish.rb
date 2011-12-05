# encoding: utf-8
class Dish < ActiveRecord::Base
  attr_accessible :image_sd, :image_hd
  
  
  belongs_to :restaurant
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
  belongs_to :network
  has_many :reviews
  
  belongs_to :restaurant_cc, :class_name => 'Restaurant', 
               :conditions => ['cc = ?', 1]
  
  mount_uploader :photo, ImageUploader
  
  def find_image
    if photo.blank?
      review = Review.where("dish_id = ?", id).order('count_likes DESC').first.photo
    else
      photo
    end
  end
  
  def image_sd
    find_image.iphone.url
  end
  
  def image_hd
    find_image.iphone_retina.url
  end
  
  def self.near(lat, lon, rad = 1)
    where("((ACOS(
      SIN(restaurants.lat * PI() / 180) * SIN(? * PI() / 180) + 
      COS(restaurants.lat * PI() / 180) * COS(? * PI() / 180) * 
      COS((? - restaurants.lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344 <= ?", lat, lat, lon, rad)
  end
  
  def self.find_by_keyword(keyword)
    keywords = {:salad => 'салат',
      :soup => 'суп',
      :pasta => 'паста',
      :pizza => 'пицца',
      :burger => 'бургер',
      :noodles => 'лапша',
      :risotto => 'ризотто',
      :rice => 'рис',
      :stake => 'стэйк',
      :sushi => 'суши и роллы',
      :desserts => 'десерты',
      :drinks => 'напитки',
      :meat => 'мясо',
      :fish => 'рыба',
      :vegetables => 'овощи'}
    
    where("dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE `name` LIKE ?) 
          OR 
          dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE `name` LIKE ?)
          ", keywords[:"#{keyword}"], keywords[:"#{keyword}"]) unless keywords[:"#{keyword}"].blank?
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
        :image_sd => review.photo.iphone.url != '/images/noimage.jpg' ? review.photo.iphone.url : '' ,
        :image_hd => review.photo.iphone_retina.url != '/images/noimage.jpg' ? review.photo.iphone_retina.url : '',
        :user_id => review.user_id,
        :user_name => review.user.name,
        :user_avatar => "http://graph.facebook.com/#{review.user.facebook_id}/picture?type=square",
        :text => review.text,
        :rating => review.rating
      })
    end
    
    restaurants = []
    dish.network.restaurants.each do |restaurant|
      restaurants.push({
        :address => restaurant.address,
        :phone => restaurant.phone.to_s,
        :working_hours => restaurant.time,
        :lat => restaurant.lat,
        :lon => restaurant.lon,
        :description => restaurant.description.to_s
      })
    end
    
    data = {
      :current_user_rating => user_review ? user_review.rating : '',
      :photo => dish.find_image.iphone.url != '/images/noimage.jpg' ? dish.find_image.iphone.url : '' ,
      :rating => dish.rating,
      :votes => dish.votes,
      :position_in_network => position_in_network,
      :dishes_in_network => dish.network.dishes.count,
      :position_in_type => position_in_type,
      :dishes_in_type => dish.dish_type.dishes.count,
      :type_name => dish.dish_type.name,
      :subtype_name => dish.dish_subtype ? dish.dish_subtype.name : '',
      :restaurant_name => dish.network.name, 
      :restaurant_id => dish.network.restaurants.first.id, 
      :description => dish.description.to_s,
      :reviews => reviews,
      :top_expert => {
        :user_name => top_expert.name,
        :user_avatar => "http://graph.facebook.com/#{top_expert.facebook_id}/picture?type=square",
        :user_id => top_expert.id
      },
      :restaurants => restaurants,
      :error => {:description => nil, :code => nil}
      
    }
    data.as_json
  end
  
end
