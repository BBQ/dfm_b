class DishDelivery < ActiveRecord::Base
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
end
