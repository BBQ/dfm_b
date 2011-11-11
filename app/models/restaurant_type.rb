class RestaurantType < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :type
end