class Network < ActiveRecord::Base
  
  has_many :dishes
  has_many :restaurants
  has_many :reviews
    
  default_scope order('rating DESC')
  mount_uploader :photo, ImageUploader 

end