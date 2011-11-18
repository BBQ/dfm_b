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
  
  def geo_address
    [city, address].compact.join(', ').gsub(/ТРЦ.*|ТЦ.*|ТК.*|ТДК.*|\(.*|Бизнес.*|к\/т.*|СКК.*|МО,|гостиница.*/, '')
  end
    
  def as_json(options={})
    self[:rating] = self.network.rating
    self[:votes] = self.network.votes
    
    super(:only => [:id, :name, :address, :rating, :votes, :lat, :lon], :methods => :dish_images )
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
        photos.push(review.photo.iphone.url)
      end
    end
    photos
  end
  
  def self.near(lat, lon, rad = 1)
    where("((ACOS(SIN(? * PI() / 180) * SIN(lat * PI() / 180) +
        COS(? * PI() / 180) * COS(lat * PI() / 180) * COS((? - lon) * 
        PI() / 180)) * 180 / PI()) * 60 * 1.1515 * 1.609344) <= ?", lat, lat, lon, rad)
  end
  
  def self.by_distance(lat, lon)
    order("(ACOS(SIN(#{lat} * PI() / 180) * SIN(lat * PI() / 180) +
        COS(#{lat} * PI() / 180) * COS(lat * PI() / 180) * COS((#{lon} - lon) * 
        PI() / 180)) * 180 / PI()) * 60 * 1.1515 * 1.609344")
  end
  
end
