class Image < ActiveRecord::Base
  
  mount_uploader :photo, ImageUploader
  
  def self.review_photo(uuid)
    if image = find_by_uuid(uuid)
      photo = File.open(image.photo.file.file)
    end
  end
  
end
