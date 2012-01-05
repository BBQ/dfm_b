# encoding: utf-8
namespace :tags do
    
  tags = {
    :salad => '(салат|salad|салатик)',
    :soup => '(soup|суп|супы|супчик|супчики|супец)',
    :pasta => '(pasta|паста|пасты|спагетти)',
    :pizza => '(pizza|пицца|пиццы)',
    :burger => '(burger|бургер)',
    :noodles => '(noodles|лапша)',
    :risotto => '(risotto|ризотто)',
    :rice => '(rice|рис)',
    :steak => '(steak|стейк|стэйк)',
    :sushi => '(sushi & rolls|суши и роллы|суши|sushi|ролл|сашими)',
    :desserts => '(desserts|десерт|торт|пирожные|пирожное|выпечка|мороженое|пирог|сладости|сорбет)',
    :drinks => '(drinks|напитки|напиток)',
    :meat => '(meat|мясо|мясное)',
    :fish => '(fish|рыба|морепродукты|креветки|мидии|форель|треска|карп|моллюски|устрицы|сибас|лосось|судак)',
    :vegetables => '(vegetables|овощи|овощь)'
  }
  
  ids = {
    1 => ['салат','salad','салатик'],
    2 => ['soup','суп','супы','супчик','супчики','супец'],
    3 => ['pasta','паста','пасты','спагетти'],
    4 => ['pizza','пицца','пиццы'],
    5 => ['burger','бургер'],
    6 => ['noodles','лапша'],
    7 => ['risotto','ризотто'],
    8 => ['rice','рис'],
    9 => ['steak','стейк','стэйк'],
    10 => ['sushi & rolls','суши и роллы','суши','sushi','ролл','сашими'],
    11 => ['desserts','десерт','торт','пирожные','пирожное','выпечка','мороженое','пирог','сладости','сорбет'],
    12 => ['drinks','напитки','напиток'],
    13 => ['meat','мясо','мясное'],
    14 => ['fish','рыба','морепродукты','креветки','мидии','форель','треска','карп','моллюски','устрицы','сибас','лосось','судак'],
    15 => ['vegetables','овощи','овощь']
  }
             
  
  desc "Add Tags to the table"
  task :add => :environment do
    
    tags.each {|key, value| Tag.create(:name => key) unless Tag.find_by_name(key) }
    p 'done!'
  end
  
  desc "Add Tags to table from excel file"
  task :add_excel => :environment do
    
    require 'csv'

    directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/'
    file = directory + 'Catogories.xlsx'
    parser = Excelx.new(file, false, :ignore)  

    dish_sheet = parser.sheets[7]
    2.upto(parser.last_row(dish_sheet)) do |line|      
      name1 = parser.cell(line,'B', dish_sheet).downcase
      name2 = parser.cell(line,'C', dish_sheet)
      
      exist = 0
      ids.each {|k,v| exist = 1 if v.include?(name1)}
      
      if name2.nil? && exist == 0
        unless Tag.find_by_name(name1)
          Tag.create(:name => name1)
          p "#{name1} Created"
        else 
          p "#{name1} Exist"
        end        
      end
    end
      p 'done!'
  end
  
  desc "Add Tags to the table"
  task :match => :environment do
    Tag.where("id > 15").each do |t|
      
      tag_id = t.id     
      
      # Restaurants
      rs = Restaurant.where("restaurants.network_id IN ( SELECT DISTINCT network_id FROM dishes WHERE 
          dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE LOWER(dish_categories.`name`) REGEXP '[[:<:]]#{t.name}[[:>:]]')
          OR 
          dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE LOWER(dish_types.`name`) REGEXP '[[:<:]]#{t.name}[[:>:]]')
          OR
          dishes.dish_subtype_id IN (SELECT DISTINCT id FROM dish_subtypes WHERE LOWER(dish_subtypes.`name`) REGEXP '[[:<:]]#{t.name}[[:>:]]')
          OR
          LOWER(dishes.`name`) REGEXP '[[:<:]]#{t.name}[[:>:]]'
          OR
          LOWER(restaurants.`name`) REGEXP '[[:<:]]#{t.name}[[:>:]]')")
      
      rs.each do |r|
        if tag_id
          RestaurantTag.create(:tag_id => tag_id, :restaurant_id => r.id)
        else
          p 'Ouppps! R!'
        end
      end
      
      # Dishes      
      ds = Dish.where("dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE LOWER(dish_categories.`name`) REGEXP '[[:<:]]#{t.name}[[:>:]]') 
            OR 
            dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE LOWER(dish_types.`name`) REGEXP '[[:<:]]#{t.name}[[:>:]]')
            OR
            dishes.dish_subtype_id IN (SELECT DISTINCT id FROM dish_subtypes WHERE LOWER(dish_subtypes.`name`) REGEXP '[[:<:]]#{t.name}[[:>:]]')
            OR 
            LOWER(dishes.`name`) REGEXP '[[:<:]]#{t.name}[[:>:]]'")
      
      ds.each do |d|
        if tag_id
          DishTag.create(:tag_id => tag_id, :dish_id => d.id)
        else
          p 'Ouppps! D!'
        end
      end
    end
  end
  
end