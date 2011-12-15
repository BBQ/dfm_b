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
      :stake => '(stake|стейк|стэйк)',
      :sushi => '(sushi & rolls|суши и роллы|суши|ролл|сашими)',
      :desserts => '(desserts|десерт|торт|пирожные|пирожное|выпечка|мороженое|пирог|сладости|сорбет)',
      :drinks => '(drinks|напитки|напиток)',
      :meat => '(meat|мясо|мясное)',
      :fish => '(fish|рыба|морепродукты|креветки|мидии|форель|треска|карп|моллюски|устрицы|сибас|лосось|судак)',
      :vegetables => '(vegetables|овощи|овощь)'
    }  
    keyword = keywords[:"#{keyword}"].blank? ? keyword : keywords[:"#{keyword}"]
    
    where("restaurants.network_id IN ( SELECT DISTINCT network_id FROM dishes WHERE 
              dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE `name` REGEXP '[[:<:]]#{keyword.downcase}')
              OR 
              dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE `name` REGEXP '[[:<:]]#{keyword.downcase}')
              OR
              LOWER(dishes.name) REGEXP '[[:<:]]#{keyword.downcase}'
              OR
              LOWER(restaurants.name) REGEXP '[[:<:]]#{keyword.downcase}'
            )", keyword, keyword)
  end
  
  def geo_address
    [city, address].compact.join(', ').gsub(/ТРЦ.*|ТЦ.*|ТК.*|ТДК.*|\(.*|Бизнес.*|к\/т.*|СКК.*|МО,|гостиница.*/, '')
  end
    
  def as_json(options={})
    self[:rating] = self.network.rating
    self[:votes] = self.network.votes
    
    super(:only => [:id, :name, :address, :rating, :votes, :lat, :lon], :methods => :dishes )
  end
  
  def find_image
    if photo.blank?
      dish = Dish.where("network_id = ?", network_id).order('rating DESC, votes DESC').first.find_image if Dish.find_by_network_id(network_id)
    else
      photo
    end
  end
  
  def dishes
    num_images = 20
    photos = []
    dishes = Network.find_by_id(network_id).dishes.order('photo DESC')
    
    dishes.take(num_images).each do |dish|
      if dish.photo && dish.photo.iphone.url != '/images/noimage.jpg'
        photos.push({
          :id => dish.id,
          :photo => dish.photo.iphone.url
        })
      end
    end
    
    if photos.count < num_images
      reviews = Review.where('network_id = ?', network.id).order('count_likes DESC')
      reviews.take(num_images - photos.count).each do |review|
        if review.photo && review.photo.iphone.url != '/images/noimage.jpg'
          photos.push({
            :id => review.dish_id,
            :photo => review.photo.iphone.url
          })
        end
      end
    end
    photos
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
      COS((#{lon} - lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344")
  end

end
