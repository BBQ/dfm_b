class DishType < ActiveRecord::Base
  has_many :dishes
end
