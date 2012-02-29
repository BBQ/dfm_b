class HomeCook < ActiveRecord::Base
  
    mount_uploader :photo, ImageUploader
    
end
