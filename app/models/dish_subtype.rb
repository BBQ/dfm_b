class DishSubtype < ActiveRecord::Base
  has_many :dishes
  has_many :dish_deliveries
  belongs_to :dish_type  
end
