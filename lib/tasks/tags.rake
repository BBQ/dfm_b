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
             

  desc "Add Tags to the table from excel file"
  task :add_excel => :environment do
    
    require 'csv'

    directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/'
    file = directory + 'Catogories.xlsx'
    parser = Excelx.new(file, false, :ignore)  

    dish_sheet = parser.sheets[4]
    2.upto(parser.last_row(dish_sheet)) do |line|   
      
      data = {        
        :name_a => parser.cell(line,'A', dish_sheet),
        :name_b => parser.cell(line,'B', dish_sheet),
        :name_c => parser.cell(line,'C', dish_sheet),
        :name_d => parser.cell(line,'D', dish_sheet),
        :name_e => parser.cell(line,'E', dish_sheet),
        :name_f => parser.cell(line,'F', dish_sheet)
      }
      
      unless Tag.find_by_name_a(data[:name_a])
        Tag.create(data)
        p "#{data} Created"
      else 
        p "#{data} Exist"
      end
      
    end
      p 'done!'
  end
  
  desc "Match Restaurant Tags"
  task :match_rest => :environment do
    Network.all.each do |n|
     n.restaurants.each do |r|
       dishes_id = []
       r.network.dishes.each do |d|
         dishes_id.push(d.id)
       end
       dishes_id.join(',')
       DishTag.select("DISTINCT tag_id").where("dish_id IN (?) AND tag_id = 298", dishes_id).each do |t|
          data = {
            :tag_id => t.tag_id, 
            :restaurant_id => r.id
          }
          p "#{data}"
          RestaurantTag.create(data)
       end
     end
   end
     p 'It`s done!'
   end
  
  desc "Match Dish Tags"
  task :match_dishes => :environment do
    tags  = Tag.where("id = 298")
    # tags  = Tag.all
    # tags = Tag.where('id in(SELECT tags.id, dish_tags.tag_id FROM tags LEFT JOIN dish_tags on tags.id = dish_tags.tag_id GROUP BY tags.name_a HAVING dish_tags.tag_id IS NULL)')
    
    tags.each do |t|
      
      tag_id = t.id
      names_array = []
      
      names_array.push(t.name_a.downcase) unless t.name_a.blank? 
      names_array.push(t.name_b.downcase) unless t.name_b.blank? 
      names_array.push(t.name_c.downcase) unless t.name_c.blank? 
      names_array.push(t.name_d.downcase) unless t.name_d.blank? 
      names_array.push(t.name_e.downcase) unless t.name_e.blank? 
      names_array.push(t.name_f.downcase) unless t.name_f.blank? 
      names = names_array.join('|').gsub(/\\|'/) { |c| "\\#{c}" }
      
      # Dishes      
      ds = Dish.where("
            dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE LOWER(dish_categories.`name`) REGEXP '[[:<:]]#{names}[[:>:]]') 
            OR 
            dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE LOWER(dish_types.`name`) REGEXP '[[:<:]]#{names}[[:>:]]')
            OR
            dishes.dish_subtype_id IN (SELECT DISTINCT id FROM dish_subtypes WHERE LOWER(dish_subtypes.`name`) REGEXP '[[:<:]]#{names}[[:>:]]')
            OR 
            LOWER(dishes.`name`) REGEXP '[[:<:]]#{names}[[:>:]]'")
      
      ds.each do |d|
        data = {
          :tag_id => tag_id, 
          :dish_id => d.id
        }
        p "#{data}"
        DishTag.create(data)
      end
    end
    p 'It`s done!'
  end
  
  desc "Match Tags"
  task :match_old => :environment do
    Tag.each do |t|
      
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