# encoding: utf-8
namespace :fix do
  
  task :set_zero => :environment do

    Restaurant.all.each do |r|
      # fix wifi
      if r.wifi.to_i == '1' || r.wifi == 'true' || r.wifi == 'да'
        r.wifi = 1
      else
        r.wifi = 0
      end 
      r.save
    end
    puts 'done!'
  end
  
  task :likes => :environment do
    Review.all.each do |r|
      r.count_likes = r.likes.count
      r.save
    end
  end
  
end