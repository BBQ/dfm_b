# encoding: utf-8
task :cleanup => :environment do

  Restaurant.where("source = 'xlst'").each do |r|
    d = 1
    r.reviews.each {|rw| d = 0 if rw.restaurant_id == r.id}
    r.destroy if d == 1
    r.network.dishes.each {|d| d.destroy if d.reviews.count < 1}
  end
  puts 'done!'
end