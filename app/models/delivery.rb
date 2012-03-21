class Delivery < ActiveRecord::Base
  has_many :dish_deliveries, :foreign_key => :dish_category_id
  has_many :reviews, :foreign_key => :restaurant_id 
  
  has_many :deliveries_tags, :dependent => :destroy
  has_many :tags, :through => :deliveries_tags
end
