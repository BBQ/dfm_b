# encoding: utf-8
task :xls => :environment do  
  current_path = File.dirname(__FILE__).sub('/lib/tasks', '')+ '/import/Data1'
  path = current_path + "/20111126_1_base.xlsx"
  parser = Excelx.new(path, false, :ignore)
   
  # Parse Restaurants
  3.upto(parser.last_row) do |line|
    
    unless Restaurant.find_by_address_and_name(parser.cell(line,'E'), parser.cell(line,'B').capitalize_first_letter)
      
      network = parser.cell(line,'B').capitalize_first_letter.gsub(/^\p{Space}+|\p{Space}+$/, "")
      network_id = Network.find_by_name(network) ? Network.find_by_name(network).id : Network.create(:name => network).id
      file = parser.cell(line,'K') ? parser.cell(line,'K') : ''
      photo = File.open(current_path + '/img/' + file) if File.file?(current_path + '/img/' + file)

      restaurant_data = [:name => parser.cell(line,'B').capitalize_first_letter,
        :city => parser.cell(line,'C').strip.gsub(/г\./, ''),
        :address => parser.cell(line,'E'),
        :time => parser.cell(line,'G'),
        :phone => parser.cell(line,'F'),
        :web => parser.cell(line,'J'),
        :breakfast => parser.cell(line,'P'),
        :businesslunch => parser.cell(line,'O'),
        #:photo => photo,
        :network_id => network_id,
        :wifi => parser.cell(line,'L') || 0,
        :chillum => parser.cell(line,'M') || 0,
        :terrace => parser.cell(line,'N') || 0,
        :cc => parser.cell(line,'Q') || 0,
        :source => 'xlst'
        ]
    
      restaurants = Restaurant.create(restaurant_data)
      puts "#{line}: #{restaurants.first.geo_address}}"
      
      RestaurantImage.create(:photo => photo, :restaurant_id => restaurants.first.id)

      parser.cell(line,'I').split(',').each do |cuisine|
        cuisine.gsub!(/^\p{Space}+|\p{Space}+$/, "")
        cuisine.downcase!
        if c = Cuisine.find_by_name(cuisine)
          cuisine_id = c.id
        else
          cuisine_id = Cuisine.create(:name => cuisine).id
        end
        RestaurantCuisine.create(:cuisine_id => cuisine_id, :restaurant_id => restaurants.first.id)
      end
    
      parser.cell(line,'H').split(',').each do |type|
        type.gsub!(/^\p{Space}+|\p{Space}+$/, "")
        type.downcase!
        if t = Type.find_by_name(type)
          type_id = t.id
        else
          type_id = Type.create(:name => type).id
        end
        RestaurantType.create(:type_id => type_id, :restaurant_id => restaurants.first.id)
      end  
    end
  end
  
  #Parse Dishes   
  dish_sheet = parser.sheets[1]
  3.upto(parser.last_row(dish_sheet)) do |line|

    network = parser.cell(line,'B', dish_sheet).capitalize_first_letter.gsub(/^\p{Space}+|\p{Space}+$/, "") if parser.cell(line,'B', dish_sheet)
    dish_network_id = Network.find_by_name(network) ? Network.find_by_name(network).id : 0
    name = parser.cell(line,'D', dish_sheet).strip.gsub(/'\s|\s'|[“”‛’»«`]/, '"') if parser.cell(line,'D', dish_sheet)
        
    if parser.cell(line,'D', dish_sheet) && !Dish.find(:first, :first, :conditions => [ "network_id = :id AND name = :name", { :id => dish_network_id, :name => name}])     
      dish_category = parser.cell(line,'C', dish_sheet).downcase.gsub(/^\p{Space}+|\p{Space}+$/, "") if parser.cell(line,'C', dish_sheet)
      dish_category_id = DishCategory.find_by_name(dish_category) ? DishCategory.find_by_name(dish_category).id : DishCategory.create(:name => dish_category).id

      dish_type = parser.cell(line,'G', dish_sheet).downcase.gsub(/^\p{Space}+|\p{Space}+$/, "") if parser.cell(line,'G', dish_sheet)
      dish_type_id = DishType.find_by_name(dish_type) ? DishType.find_by_name(dish_type).id : DishType.create(:name => dish_type).id

      file = parser.cell(line,'H',dish_sheet) ? parser.cell(line,'H',dish_sheet) : ''
      photo = File.open(current_path + '/img/' + file) if File.file?(current_path + '/img/' + file)
      description = parser.cell(line,'E', dish_sheet).gsub(/'\s|\s'|[“”‛’»«`]/, '"').strip if parser.cell(line,'E', dish_sheet)

      dish_data = [:name => name,
        :photo => photo,
        :price => parser.cell(line,'F', dish_sheet),
        :description => description,
        :dish_category_id => dish_category_id,
        :dish_type_id => dish_type_id,
        :network_id => dish_network_id,
        :currency => 'RUR',
        :dish_subtype_id => 0,
      ]
      
      puts "#{line} : #{name}"
      Dish.create(dish_data)
      # puts dish_data
    end
  end
end
