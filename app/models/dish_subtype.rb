class DishSubtype < ActiveRecord::Base
  has_many :dishes
  belongs_to :dish_type  
end
