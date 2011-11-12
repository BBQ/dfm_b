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
    super(:only => [:id, :name, :address, :rating, :votes, :lat, :lon])
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
