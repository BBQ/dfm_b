# encoding: utf-8
namespace :tags do
    
  desc "Match Restaurant Tags RUN ONLY AFTER :match_dishes"
  task :match_rest => :environment do
    restaurants = ENV["TYPE"] == 'Delivery' ? Delivery : Restaurant
    
    if ENV["NETWORK_ID"]
      restaurants = restaurants.where(:network_id => ENV["NETWORK_ID"])
    else
      restaurants = restaurants.where("id >= 82977")
    end
          
    restaurants.each do |r|
      p "#{r.id}:#{r.name}"
    
     unless dishes_id = ENV["DISH_ID"]
       dishes_id = []
       r.network.dishes.each do |d|
         dishes_id.push(d.id)
       end
       dishes_id.join(',')
     end
 
     tags = DishTag.select("DISTINCT tag_id").where("dish_id IN (?)", dishes_id)
     tags.each {|t| RestaurantTag.create(:tag_id => t.tag_id, :restaurant_id => r.id)}
    end
    
     p 'All done!'
   end
  
  desc "Match Dish Tags"
  task :match_dishes => :environment do
    
    Tag.all.each do |t|
      p t.name_a
      
      names_array = []      
      names_array.push(t.name_a.downcase) unless t.name_a.blank? 
      names_array.push(t.name_b.downcase) unless t.name_b.blank? 
      names_array.push(t.name_c.downcase) unless t.name_c.blank? 
      names_array.push(t.name_d.downcase) unless t.name_d.blank? 
      names_array.push(t.name_e.downcase) unless t.name_e.blank? 
      names_array.push(t.name_f.downcase) unless t.name_f.blank? 
      names = names_array.join('|').gsub(/\\|'/) { |c| "\\#{c}" }
      
      # Dishes
      ds = ENV["TYPE"] == 'Delivery' ? DishDelivery : Dish
      ds = ds.where("
            dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE LOWER(dish_categories.`name`) REGEXP '[[:<:]]#{names}[[:>:]]') 
            OR 
            dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE LOWER(dish_types.`name`) REGEXP '[[:<:]]#{names}[[:>:]]')
            OR
            dishes.dish_subtype_id IN (SELECT DISTINCT id FROM dish_subtypes WHERE LOWER(dish_subtypes.`name`) REGEXP '[[:<:]]#{names}[[:>:]]')
            OR 
            LOWER(dishes.`name`) REGEXP '[[:<:]]#{names}[[:>:]]'")
            
      ds = ds.where(:network_id => ENV["NETWORK_ID"]) if ENV["NETWORK_ID"]
      ds = ds.where(:id => ENV["DISH_ID"]) if ENV["DISH_ID"]
      
      ds.each {|d| DishTag.create(:tag_id => t.id, :dish_id => d.id)}
    end
    p 'All done!'
  end
  
end