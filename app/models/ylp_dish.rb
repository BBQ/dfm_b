class YlpDish < ActiveRecord::Base
  belongs_to :ylp_restaurant
  
  validates :ylp_restaurant_id, :uniqueness => {:scope => [:name]}
end
