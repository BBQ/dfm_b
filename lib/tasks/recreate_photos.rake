# encoding: utf-8
task :photo_rc => :environment do

  Dish.all.each do |dish|
    if dish.photo?
      
      path = File.dirname(File.expand_path(File.basename(dish.photo.to_s))) + "/public/uploads/dish/photo/#{dish.id}/"
      file_db = path + 'square_' + File.basename(dish.photo.to_s)
    
      unless File.exist?(file_db)      
        begin
          dish.photo.square.cache!(dish.photo.file) 
          dish.photo.square.store!
      
          file_generated = path + File.basename(dish.photo.square.to_s)
          File.rename(file_generated, file_db)
          puts File.basename(file_db)
        rescue
          puts "something wrong with #{dish.photo}"
        end
      end
      
    end
    # dish.photo.recreate_versions! 
  end

end