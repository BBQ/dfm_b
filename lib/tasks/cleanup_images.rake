# encoding: utf-8
task :cup_images => :environment do

  directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/public/uploads/'
  require 'fileutils'
  
  dishes = directory + 'dish/photo/'
  Dir[dishes + '*'].each do |dish|
    if d = Dish.find_by_id(dish.sub(dishes, ''))
      p d.name
      fies_in_folder = Dir[dish + '/*']
      if fies_in_folder.count > 7
        fies_in_folder.each do |f|
          photo = File.basename(d.photo.url)[0, File.basename(d.photo.url).index('.')]
          unless File.basename(f).to_s.index(photo)
            p f 
            FileUtils.rm_rf f
          end
        end
      end
    else
      p dish
      FileUtils.rm_rf dish
    end
  end
  
  reviews = directory + 'review/photo/'
   Dir[reviews + '*'].each do |review|
     if r = Review.find_by_id(review.sub(reviews, ''))
       p r.dish.name
       fies_in_folder = Dir[review + '/*']
       if fies_in_folder.count > 7
           fies_in_folder.each do |f|
             photo = File.basename(r.photo.url)[0, File.basename(r.photo.url).index('.')]
             unless File.basename(f).to_s.index(photo)
               p f 
               FileUtils.rm_rf f
             end
           end
         end
     else
       p review
       FileUtils.rm_rf review
     end
   end
  
  restaurant_images = directory + 'restaurant_image/photo/'
  Dir[restaurant_images + '*'].each do |restaurant_image|
    if r = RestaurantImage.find_by_id(restaurant_image.sub(restaurant_images, ''))
      if r.restaurant.nil?
        p restaurant_image
        r.destroy
      else
        fies_in_folder = Dir[restaurant_image + '/*']
        if fies_in_folder.count > 7
          fies_in_folder.each do |f|
            photo = File.basename(r.photo.url)[0, File.basename(r.photo.url).index('.')]
            unless File.basename(f).to_s.index(photo)
              p f 
              FileUtils.rm_rf f
            end
          end
        end
      end
    else
      p restaurant_image
      FileUtils.rm_rf restaurant_image
    end
  end
  
  restaurant_images = directory + 'restaurant_image/photo/'
  RestaurantImage.all.each do |i|
    if Dir["#{restaurant_images}#{i.id}"].blank?
      p i.id
      i.destroy 
    end
  end
    
end