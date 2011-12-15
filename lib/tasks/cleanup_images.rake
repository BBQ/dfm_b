# encoding: utf-8
task :cup_images => :environment do

  directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/public/uploads/'
  require 'fileutils'
  
  # dishes = directory + 'dish/photo/*'
  # Dir[dishes].each do |dish|
  #   if d = Dish.find_by_id(dish.sub(directory + 'dish/photo/', ''))
  #     p d.name
  #   else
  #     p dish
  #     FileUtils.rm_rf dish
  #   end
  # end
  # 
  # reviews = directory + 'review/photo/*'
  # Dir[reviews].each do |review|
  #   if r = Review.find_by_id(review.sub(directory + 'review/photo/', ''))
  #     p r.dish.name
  #   else
  #     p review
  #     FileUtils.rm_rf review
  #   end
  # end
  
  restaurant_images = directory + 'restaurant_image/photo/*'
  Dir[restaurant_images].each do |restaurant_image|
    if r = RestaurantImage.find_by_id(restaurant_image.sub(directory + 'restaurant_image/photo/', ''))
      if r.restaurant.nil?
        p '1'+restaurant_image
        # r.destroy
      else # if r.restaurant.photo.url != "/images/noimage.jpg"
        p r.id.to_s+r.restaurant.photo.url
      end
    else
      p '3'+restaurant_image
      # FileUtils.rm_rf restaurant_image
    end
  end
    
end