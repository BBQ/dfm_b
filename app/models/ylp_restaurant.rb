class YlpRestaurant < ActiveRecord::Base
  has_many :ylp_dishes
  validates :ylp_uri, :uniqueness => true
end
