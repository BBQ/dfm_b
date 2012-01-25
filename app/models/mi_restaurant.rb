class MiRestaurant < ActiveRecord::Base
  has_many :mi_dishes, :foreign_key => 'restaurant_id', :dependent => :destroy
  
  def self.by_distance(lat, lon)
    order("((ACOS(
      SIN(#{lat} * PI() / 180) * SIN(latitude * PI() / 180) +
      COS(#{lat} * PI() / 180) * COS(latitude * PI() / 180) * 
      COS((#{lon} - longitude) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344")
  end
  
end
