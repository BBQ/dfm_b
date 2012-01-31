class DishTag < ActiveRecord::Base
  belongs_to :dish
  belongs_to :tag
end
