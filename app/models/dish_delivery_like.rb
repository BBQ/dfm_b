class DishDeliveryLike < ActiveRecord::Base
  belongs_to :dish_delivery
  belongs_to :user
end
