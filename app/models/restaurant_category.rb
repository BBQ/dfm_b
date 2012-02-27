class RestaurantCategory < ActiveRecord::Base
  has_many :restaurants
end
