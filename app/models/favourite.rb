class Favourite < ActiveRecord::Base

  belongs_to :dish
  belongs_to :restaurant
  belongs_to :delivery
  belongs_to :dish_delivery
  belongs_to :home_cook
  belongs_to :network
  belongs_to :user
    
  validates :user_id, :uniqueness => {:scope => [:dish_id, :restaurant_id, :delivery_id, :dish_delivery_id, :home_cook_id]}  
    
end
