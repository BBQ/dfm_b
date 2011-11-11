class Image < ActiveRecord::Base
  mount_uploader :photo, ImageUploader
end
