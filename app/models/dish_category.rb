class DishCategory < ActiveRecord::Base
  has_many :dishes
end
