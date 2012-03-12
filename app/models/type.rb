class Type < ActiveRecord::Base
  
  has_many :restaurant_types
  has_many :restaurants, :through => :restaurant_types
  
end