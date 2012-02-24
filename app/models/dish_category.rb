class DishCategory < ActiveRecord::Base
  has_many :dishes
  has_many :dish_deliveries
end
