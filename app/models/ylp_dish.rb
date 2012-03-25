class YlpDish < ActiveRecord::Base
  belongs_to :ylp_restaurant
  
  validates :ylp_restaurant, :uniqueness => {:scope => [:name]}
end
