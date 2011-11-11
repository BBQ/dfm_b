class Network < ActiveRecord::Base
  has_many :dishes
  has_many :restaurants
    
  mount_uploader :photo, ImageUploader 
  default_scope order('rating/votes DESC')
end