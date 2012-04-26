class DishCategoryOrder < ActiveRecord::Base
  belongs_to :dish_categorty
  belongs_to :restaurant
end
