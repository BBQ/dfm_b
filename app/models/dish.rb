# encoding: utf-8
class Dish < ActiveRecord::Base
  attr_accessible :image_sd, :image_hd
  
  
  belongs_to :restaurant
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
  belongs_to :network
  has_many :reviews
  
  mount_uploader :photo, ImageUploader
  
  def find_image
    if photo.blank?
      review = Review.where("dish_id = ?", id).order('count_likes DESC').first.photo if Review.find_by_dish_id(id)
    else
      photo
    end
  end
  
  def image_sd
    find_image && find_image.iphone.url != '/images/noimage.jpg' ? find_image.iphone.url  : ''
  end
  
  def image_hd
    find_image && find_image.iphone_retina.url != '/images/noimage.jpg' ? find_image.iphone_retina.url  : ''
  end
  
  def self.near(lat, lon, rad = 1)
    where("((ACOS(
      SIN(restaurants.lat * PI() / 180) * SIN(? * PI() / 180) + 
      COS(restaurants.lat * PI() / 180) * COS(? * PI() / 180) * 
      COS((? - restaurants.lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344 <= ?", lat, lat, lon, rad)
  end
  
  def self.search_for_keyword(keyword)
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
      
    keyword = keywords[:"#{keyword}"].blank? ? keyword : keywords[:"#{keyword}"]
    
    where("dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE `name` LIKE ?) 
          OR 
          dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE `name` LIKE ?)
          OR LOWER(dishes.name) REGEXP '[[:<:]]#{keyword.downcase}'", keyword, keyword)
  end
  
end
