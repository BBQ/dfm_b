class Dish < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
  belongs_to :network
  has_many :reviews
  
  # default_scope order('rating/votes DESC, photo DESC')
  
  mount_uploader :photo, ImageUploader
end
