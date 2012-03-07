class HomeCook < ActiveRecord::Base
  
    mount_uploader :photo, ImageUploader
    has_many :reviews, :dependent => :destroy
    
end
