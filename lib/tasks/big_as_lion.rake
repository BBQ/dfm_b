# encoding: utf-8
task :biglion => :environment do
  require 'open-uri'
  require 'json'

  json_object = JSON.parse(open("http://api.biglion.ru/api.php?version=1.0&type=json&type=json&key=ab177cad952b5c9627ea84e54010c76e&method=get_rw_places&city_id=1&cat_id=1&limit=4932").read)  
  json_object.each do |obj|
    obj[1]['places'].each do |place|
      if !Restaurant.find_by_address_and_name(place['address'], place['title']) && place['id'] != 101719 && place['id'] != 102711 && place['id'] != 103616
      
        network = place['title'].downcase.gsub(/^\p{Space}+|\p{Space}+$/, "")
        network_id = Network.find_by_name(network) ? Network.find_by_name(network).id : Network.create(:name => network).id
        # puts "Network: #{network_id}.#{network}"
            
        # Populate Restaurant Data
        restaurant_data = {:name => place['title'],
          # :city => parser.cell(line,'C').strip.gsub(/г\./, ''),
          :network_id => network_id,
          :address => place['address'],
          :lat => place['coord'][/([0-9]+\.[0-9]+),([0-9]+\.[0-9]+)/, 2], 
          :lon => place['coord'][/([0-9]+\.[0-9]+),([0-9]+\.[0-9]+)/, 1],
          :source => 'bl'
        }
        puts "http://api.biglion.ru/api.php?version=1.0&type=json&type=json&key=ab177cad952b5c9627ea84e54010c76e&method=get_rw_place_info&place_id=#{place['id']}"
        details = JSON.parse(open("http://api.biglion.ru/api.php?version=1.0&type=json&type=json&key=ab177cad952b5c9627ea84e54010c76e&method=get_rw_place_info&place_id=#{place['id']}").read)['result']['place']  

        # Populate extra Restaurant Data
        restaurant_data[:phone] = details['tel']
        restaurant_data[:web] = details['site_url']
        restaurant_data[:menu_url] = details['menu_url']
        restaurant_data[:description] = details['description']
            
        # Populate Work hours
        day_data = Array.new
        details['whours'].each do |day|
          week_days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
          day_data.push("#{week_days[day['wday'].to_i]} #{day['work_from']} - #{day['work_till']}")        
        end
        restaurant_data[:time] = day_data.join(', ')
          
        # Populate all other Restaurant Data
        details['params'].each do |param|   

          restaurant_data[:children] = param['values'].first['value'] if param['id'] == 1
          restaurant_data[:cc] = 1 if param['id'] == 2
          restaurant_data[:parking] = param['values'].first['value'] if param['id'] == 3
          restaurant_data[:banquet] = param['values'].first['value'] if param['id'] == 5
          restaurant_data[:reservation] = param['values'].first['value'] if param['id'] == 6
          restaurant_data[:delivery] = param['values'].first['value'] if param['id'] == 7
          restaurant_data[:takeaway] = param['values'].first['value'] if param['id'] == 8
          restaurant_data[:service] = param['values'].first['value'] if param['id'] == 9
          restaurant_data[:terrace] = 1 if param['id'] == 10 && param['values'].first['value'] == 'есть'
          restaurant_data[:wifi] = param['values'].first['value'] if param['id'] == 1
        
          goods = Array.new
          if param['id'] == 12
            param['values'].each do |good|
              goods.push(good['value'])    
            end      
          end
          restaurant_data[:good_for] = goods.join(', ')
        
          alcohol = Array.new
          if param['id'] == 12
            param['values'].each do |alco|
              alcohol.push(alco['value'])   
            end       
          end
          restaurant_data[:alcohol] = alcohol.join(', ')

          restaurant_data[:noise] = param['values'].first['value'] if param['id'] == 14
          restaurant_data[:tv] = param['values'].first['value'] if param['id'] == 16
          restaurant_data[:disabled] = param['values'].first['value'] if param['id'] == 17
          restaurant_data[:businesslunch] = param['values'].first['value'] if param['id'] == 18
          restaurant_data[:music] = param['values'].first['value'] if param['id'] == 28
          restaurant_data[:bill] = param['values'].first['value'] if param['id'] == 30
        end
      
        # puts restaurant_data
        restaurant = Restaurant.create(restaurant_data)
      
        details['params'].each do |param| 
          if param['id'] == 26
            param['values'].each do |cuisine|
              cuisine['value'].gsub!(/^\p{Space}+|\p{Space}+$/, "")
              cuisine['value'].downcase!
              if c = Cuisine.find_by_name(cuisine['value'])
                cuisine_id = c.id
              else
                cuisine_id = Cuisine.create(:name => cuisine['value']).id
              end
              RestaurantCuisine.create(:cuisine_id => cuisine_id, :restaurant_id => restaurant.id)  
              # puts "RestaurantCuisine: #{cuisine_id}.#{cuisine['value']}"
            end   
          end              
          if param['id'] == 27
            param['values'].each do |type|
              type['value'].gsub!(/^\p{Space}+|\p{Space}+$/, "")
              type['value'].downcase!
              if t = Type.find_by_name(type['value'])
                type_id = t.id
              else
                type_id = Type.create(:name => type['value']).id
              end
              RestaurantType.create(:type_id => type_id, :restaurant_id => restaurant.id)
              # puts "RestaurantType: #{type_id}.#{type['value']}"   
            end  
          end
        end
      
        details['fotos'].each do |photo|
          begin
            RestaurantImage.create(:remote_photo_url => photo['image_r'], :restaurant_id => restaurant.id)
            # puts "ok! #{photo['image_r']} for Restaurant #{restaurant.id}"
          rescue OpenURI::HTTPError => ex
            # puts "missing :( #{photo['image_r']} for Restaurant #{restaurant.id}"
          end
        end
         
      end
    end  
  end
end