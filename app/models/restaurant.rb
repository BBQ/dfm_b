# encoding: utf-8
class Restaurant < ActiveRecord::Base
  
  has_many :dishes
  has_many :reviews
  belongs_to :network 
  has_many :dishes, :through => :network 
  
  has_many :restaurant_types
  has_many :types, :through => :restaurant_types
  has_many :restaurant_images, :dependent => :destroy
  
  has_many :restaurant_cuisines
  has_many :cuisines, :through => :restaurant_cuisines
  
  mount_uploader :photo, ImageUploader 
  
  # geocoded_by :geo_address, :latitude  => :lat, :longitude => :lon
  # after_validation :geocode, :if => :address_changed?
  
  def self.search_by_word(keyword)
    ids = {
      1 => ['салат','salad','салатик'],
      2 => ['soup','суп','супы','супчик','супчики','супец'],
      3 => ['pasta','паста','пасты','спагетти'],
      4 => ['pizza','пицца','пиццы'],
      5 => ['burger','бургер'],
      6 => ['noodles','лапша'],
      7 => ['risotto','ризотто'],
      8 => ['rice','рис'],
      9 => ['steak','стейк','стэйк'],
      10 => ['sushi & rolls','суши и роллы','суши','sushi','ролл','сашими'],
      11 => ['desserts','десерт','торт','пирожные','пирожное','выпечка','мороженое','пирог','сладости','сорбет'],
      12 => ['drinks','напитки','напиток'],
      13 => ['meat','мясо','мясное'],
      14 => ['fish','рыба','морепродукты','креветки','мидии','форель','треска','карп','моллюски','устрицы','сибас','лосось','судак'],
      15 => ['vegetables','овощи','овощь']
    }
    
    id = 0
    keyword.downcase!
    
    ids.each {|k,v| id = k if v.include?(keyword)}            
    if id.blank? && tag = Tag.find_by_name(keyword)
      id = tag.id
    end
    
    if id > 0
      where('restaurants.id IN (SELECT restaurant_id FROM restaurant_tags WHERE tag_id = ?)', id)
    else
      where("restaurants.network_id IN ( SELECT DISTINCT network_id FROM dishes WHERE 
                dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE LOWER(dish_categories.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
                OR 
                dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE LOWER(dish_types.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
                OR
                dishes.dish_subtype_id IN (SELECT DISTINCT id FROM dish_subtypes WHERE LOWER(dish_subtypes.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
                OR
                LOWER(dishes.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]'
                OR
                LOWER(restaurants.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]'
              )")
    end
  end
  
  def geo_address
    [city, address].compact.join(', ').gsub(/ТРЦ.*|ТЦ.*|ТК.*|ТДК.*|\(.*|Бизнес.*|к\/т.*|СКК.*|МО,|гостиница.*/, '')
  end
    
  def as_json(options={})
    self[:rating] = self.network.rating
    self[:votes] = self.network.votes
    self[:fsq_id] = self.fsq_id || ''
        
    super(:only => [:id, :name, :address, :rating, :votes, :lat, :lon, :network_id, :fsq_id])
  end
  
  def find_image
    if photo.blank?
      if dish = Dish.where("photo IS NOT NULL AND network_id = ?", network_id).order('rating DESC, votes DESC')
        dish.first.photo
      end
    else
      photo
    end
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
