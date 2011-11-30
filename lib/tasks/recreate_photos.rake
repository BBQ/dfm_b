# encoding: utf-8
task :photo_rc => :environment do

  # For dishes
  Dish.all.each do |dish|
    dish.photo.recreate_versions! if dish.photo?
    puts dish.photo
  end

end