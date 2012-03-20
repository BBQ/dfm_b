class Delivery < ActiveRecord::Base
  has_many :dish_deliveries
  
  has_many :deliveries_tags, :dependent => :destroy
  has_many :tags, :through => :deliveries_tags
end
