class DishDeliveryComment < ActiveRecord::Base
  belongs_to :dish_delivery
  belongs_to :user
  
  def delete
    dish_delivery.count_comments -= 1
    dish_delivery.save
    self.destroy
  end
  
end
