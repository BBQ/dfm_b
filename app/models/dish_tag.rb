class DishTag < ActiveRecord::Base
  belongs_to :dish
  belongs_to :tag
  set_primary_key "dish_id"
end
