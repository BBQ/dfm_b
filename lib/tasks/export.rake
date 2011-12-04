# encoding: utf-8
task :export => :environment do
  
  require 'csv'
  
  i = 0
  CSV.open("dish_reviews.csv", "w") do |csv|
    csv << ["ID Dish; Restaurant; Category (resto); Dishes; Description; Price; Our Category; Фото блюда; Группа; Тег;"]
    Dish.where("dish_category_id = 120").each do |dish|
      puts i += 1
     csv << ["#{dish.id};#{dish.restaurant ? dish.restaurant.name.gsub(';', '') : ''};;#{dish.name.gsub(';', '')};;#{dish.price};#{dish.dish_category ? dish.dish_category.name : ''};;;;"]
     # puts"0;#{dish.restaurant ? dish.restaurant.name : ''};;#{dish.name};#{dish.description};#{dish.price};#{dish.category ? dish.category.name : ''};;;;"
    end
  end
end