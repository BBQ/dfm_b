# encoding: utf-8
class Dish < ActiveRecord::Base
    
  belongs_to :restaurant
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
  belongs_to :dish_extratype
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
    keywords = {
      :salad => '(салат|salad|салатик)',
      :soup => '(soup|суп|супы|супчик|супчики|супец)',
      :pasta => '(pasta|паста|пасты|спагетти)',
      :pizza => '(pizza|пицца|пиццы)',
      :burger => '(burger|бургер)',
      :noodles => '(noodles|лапша)',
      :risotto => '(risotto|ризотто)',
      :rice => '(rice|рис)',
      :steak => '(steak|стейк|стэйк)',
      :sushi => '(sushi & rolls|суши и роллы|суши|ролл|сашими)',
      :desserts => '(desserts|десерт|торт|пирожные|пирожное|выпечка|мороженое|пирог|сладости|сорбет)',
      :drinks => '(drinks|напитки|напиток)',
      :meat => '(meat|мясо|мясное)',
      :fish => '(fish|рыба|морепродукты|креветки|мидии|форель|треска|карп|моллюски|устрицы|сибас|лосось|судак)',
      :vegetables => '(vegetables|овощи|овощь)'
    }
    keyword = keywords[:"#{keyword}"].blank? ? keyword.downcase : keywords[:"#{keyword}"]
    
    where("dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE LOWER(dish_categories.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]') 
          OR 
          dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE LOWER(dish_types.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
          OR
          dishes.dish_subtype_id IN (SELECT DISTINCT id FROM dish_subtype WHERE LOWER(dish_subtype.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
          OR 
          LOWER(dishes.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]'")
  end
  
  def self.by_distance(lat, lon)
    includes(:restaurant).order("((ACOS(
      SIN(#{lat} * PI() / 180) * SIN(restaurants.lat * PI() / 180) +
      COS(#{lat} * PI() / 180) * COS(restaurants.lat * PI() / 180) * 
      COS((#{lon} - restaurants.lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344")
  end
  
end
