class Favourite < ActiveRecord::Base

  belongs_to :dish
  belongs_to :restaurant
  belongs_to :user
  
end
