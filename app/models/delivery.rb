class Delivery < ActiveRecord::Base
  has_many :dish_deliveries
end
