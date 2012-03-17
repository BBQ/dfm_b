class RestaurantTag < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :tag
  
  validates :restaurant_id, :uniqueness => {:scope => :tag_id}  
end
