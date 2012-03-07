class DishExtratype < ActiveRecord::Base
  has_many :dishes
  has_many :home_cooks
end
