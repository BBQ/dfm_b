class DishType < ActiveRecord::Base
  has_many :dishes
  has_many :dish_subtypes
end
