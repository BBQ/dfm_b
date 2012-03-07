class DishSubtype < ActiveRecord::Base
  has_many :dishes
  has_many :home_cooks
  has_many :dish_deliveries
  belongs_to :dish_type  
end
