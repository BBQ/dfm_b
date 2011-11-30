# encoding: utf-8
require 'carrierwave/processing/mini_magick'

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog
  
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end
  
  def default_url
    "/images/noimage.jpg"
  end
  
  def filename
       @name ||= "#{secure_token}.#{file.extension}" if original_filename.present?
  end
  
  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
      process :resize_to_fit => [192, 192]
      # process :watermark =>'watermark.png'
  end
  
  version :iphone do
      process :resize_to_fit => [290, 290]
      # process :watermark =>'watermark.png'
  end
  
  version :iphone_retina do
      process :resize_to_fit => [580, 580]
      # process :watermark =>'watermark.png'
  end
  
  version :square do    
      process :resize_and_pad => [188, 188, '#F2EFE9', 'Center']
      # process :watermark =>'watermark.png'
  end
  
  
  # def watermark(file)
  #   manipulate! do |img| 
  #     img = img.composite(MiniMagick::Image.open("/users/mac/rails_projects/santinihouse/public/uploads/"+file, "jpg")) do |c|
  #         c.gravity "center"
  #     end
  #     img
  #   end 
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  
  protected  
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
    
end
