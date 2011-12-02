# encoding: utf-8
class Restaurant < ActiveRecord::Base
  
  has_many :dishes
  has_many :reviews
  belongs_to :network  
  
  has_many :restaurant_types
  has_many :restaurant_images
  has_many :types, :through => :restaurant_types
  
  has_many :restaurant_cuisines
  has_many :cuisines, :through => :restaurant_cuisines
  
  mount_uploader :photo, ImageUploader 
  
  geocoded_by :geo_address, :latitude  => :lat, :longitude => :lon
  after_validation :geocode, :if => :address_changed?
  
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
    
    where("restaurants.network_id IN ( SELECT DISTINCT network_id FROM dishes WHERE 
              dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE `name`  = ?)
              OR 
              dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE `name`  = ?)
            )", 
    keywords[:"#{keyword}"], keywords[:"#{keyword}"]) unless keyword.blank?
  end
  
  def geo_address
    [city, address].compact.join(', ').gsub(/ТРЦ.*|ТЦ.*|ТК.*|ТДК.*|\(.*|Бизнес.*|к\/т.*|СКК.*|МО,|гостиница.*/, '')
  end
    
  def as_json(options={})
    self[:rating] = self.network.rating
    self[:votes] = self.network.votes
    
    super(:only => [:id, :name, :address, :rating, :votes, :lat, :lon], :methods => :dish_images )
  end
  
  def find_image
    if photo.blank?
      dish = Dish.where("network_id = ?", network_id).order('rating/votes DESC, votes DESC').first.find_image
    else
      photo
    end
  end
  
  def dish_images
    num_images = 20
    photos = Array.new
    dishes = Network.find_by_id(network_id).dishes.order('photo DESC')
    
    dishes.take(num_images).each do |dish|
      if dish.photo && dish.photo.iphone.url != '/images/noimage.jpg'
        photos.push(dish.photo.iphone.url)
      end
    end
    
    if photos.count < num_images
      reviews = Review.where('network_id = ?', network.id).order('count_likes DESC')
      reviews.take(num_images - photos.count).each do |review|
        if review.photo && review.photo.iphone.url != '/images/noimage.jpg'
          photos.push(review.photo.iphone.url)
        end
      end
    end
    photos
  end
  
  def self.api_get_restaurant(id)
    if restaurant = Restaurant.find_by_id(id)
            
      reviews = []
      restaurant.network.reviews.each do |review|
        reviews.push({
          :image_sd => review.photo.iphone.url != '/images/noimage.jpg' ? review.photo.iphone.url : '' ,
          :image_hd => review.photo.iphone_retina.url != '/images/noimage.jpg' ? review.photo.iphone_retina.url : '',
          :user_name => review.user.name,
          :user_avatar => "http://graph.facebook.com/#{review.user.facebook_id}/picture?type=square",
          :text => review.text,
          :rating => review.rating
        })
      end
      
      restaurants = []
      restaurant.network.restaurants.each do |restaurant|
        restaurants.push({
          :address => restaurant.address,
          :phone => restaurant.phone.to_s,
          :working_hours => restaurant.time,
          :lat => restaurant.lat,
          :lon => restaurant.lon,
          :description => restaurant.description.to_s
        })
      end
      
      best_dishes = []
      restaurant.network.dishes.order("rating/votes DESC, votes DESC").take(2).each do |dish|
        best_dishes.push({
          :name => dish.name,
          :photo => dish.find_image.square.url != '/images/noimage.jpg' ? dish.find_image.square.url : '',
          :rating => dish.rating,
          :votes => dish.votes
        })
      end
      
      top_expert_id = (Review.where('network_id = ?', restaurant.network.id).group('user_id').count).max[0]
      top_expert = User.find_by_id(top_expert_id)
      better_networks = Network.where('votes >= ?', restaurant.network.votes).count.to_f
      popularity = (100 * better_networks / Network.all.count.to_f).round(0)
      
      data = {
        :network_ratings => restaurant.network.rating,
        :network_reviews_count => restaurant.network.reviews.count,
        :popularity => popularity,
        :restaurant_name => restaurant.name,
        :reviews => reviews,
        :best_dishes => best_dishes,
        :top_expert => {
          :user_name => top_expert.name,
          :user_avatar => "http://graph.facebook.com/#{top_expert.facebook_id}/picture?type=square",
          :user_id => top_expert.id
        },
        :restaurant => {
          :image_sd => restaurant.find_image.iphone.url != '/images/noimage.jpg' ? restaurant.find_image.iphone.url : '' ,
          :image_hd => restaurant.find_image.iphone_retina.url != '/images/noimage.jpg' ? restaurant.find_image.iphone_retina.url : '',
          :description => restaurant.description.to_s
        },
        :restaurants => restaurants,
        :error => {:description => '', :code => ''}
      
      }
    else
       data = {
         :error => {:description => nil, :code => nil}
       } 
    end
    data.as_json
  end
  
  def self.near(lat, lon, rad = 1)
    where("((ACOS(
    	SIN(lat * PI() / 180) * SIN(? * PI() / 180) + 
    	COS(lat * PI() / 180) * COS(? * PI() / 180) * 
    	COS((? - lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344 <= ?", lat, lat, lon, rad)
  end
  
  def self.by_distance(lat, lon)
    order("((ACOS(
      SIN(#{lat} * PI() / 180) * SIN(lat * PI() / 180) +
      COS(#{lat} * PI() / 180) * COS(lat * PI() / 180) * 
      COS((#{lon} - lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344, restaurants.rating/restaurants.votes DESC, restaurants.votes DESC")
  end
  
end
