class RestaurantImage < ActiveRecord::Base
  
    belongs_to :restaurant
    mount_uploader :photo, ImageUploader 
    
end
