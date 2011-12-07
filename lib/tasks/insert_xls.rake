# encoding: utf-8
task :xls, [:filename] => :environment do |t, args|
  
  directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/'
  file = directory + args[:filename]
  parser = Excelx.new(file, false, :ignore)  
  restaurant = String
      
  # Restaurants
  3.upto(parser.last_row) do |line|
   
    # Delete Existed
    if parser.cell(line,'B') != restaurant
     network = Network.find_by_name(parser.cell(line,'B'))
     network.restaurants.each {|r| r.destroy && r.restaurant_images.each {|i| i.destroy}}
     network.dishes.each {|d| d.destroy}
     restaurant = parser.cell(line,'B')
    end
  #     
  #   # Prepare data
  #   network = parser.cell(line,'B').capitalize_first_letter.gsub(/^\p{Space}+|\p{Space}+$/, "")
  #   network_id = Network.find_by_name(network) ? Network.find_by_name(network).id : Network.create(:name => network).id
  #   photo_file = parser.cell(line,'K') ? directory + parser.cell(line,'B') + '/' + parser.cell(line,'K') : ''
  #   photo = File.open(photo_file) if File.file?(photo_file)
  # 
  #   restaurant_data = {
  #     :id => parser.cell(line,'A').blank? ? nil : parser.cell(line,'A'),
  #     :name => parser.cell(line,'B').capitalize_first_letter,
  #     :city => parser.cell(line,'C').strip.gsub(/г\./, ''),
  #     :address => parser.cell(line,'E'),
  #     :time => parser.cell(line,'G'),
  #     :phone => parser.cell(line,'F'),
  #     :web => parser.cell(line,'J'),
  #     :breakfast => parser.cell(line,'P'),
  #     :businesslunch => parser.cell(line,'O'),
  #     :network_id => network_id,
  #     :wifi => parser.cell(line,'L') || 0,
  #     :chillum => parser.cell(line,'M') || 0,
  #     :terrace => parser.cell(line,'N') || 0,
  #     :cc => parser.cell(line,'Q') || 0,
  #     :source => 'xlst',
  #     :sun => parser.cell(line,'Y'),
  #     :mon => parser.cell(line,'S'),
  #     :tue => parser.cell(line,'T'),
  #     :wed => parser.cell(line,'U'),
  #     :thu => parser.cell(line,'V'),
  #     :fri => parser.cell(line,'W'),
  #     :sat => parser.cell(line,'X'),
  #   }
  #  
  #   # Create
  #   unless restaurant_data[:name].blank?
  #     restaurant_id = Restaurant.create(restaurant_data).id
  #     RestaurantImage.create(:photo => photo, :restaurant_id => restaurant_id)
  # 
  #     parser.cell(line,'I').split(',').each do |cuisine|
  #         cuisine.downcase!.gsub!(/^\p{Space}+|\p{Space}+$/, "")
  #         cuisine_id = Cuisine.find_by_name(cuisine) ? Cuisine.find_by_name(cuisine).id : Cuisine.create(:name => cuisine).id
  #         RestaurantCuisine.create(:cuisine_id => cuisine_id, :restaurant_id => restaurant_id)
  #     end
  # 
  #     parser.cell(line,'H').split(',').each do |type|
  #         type.downcase!.gsub!(/^\p{Space}+|\p{Space}+$/, "")
  #         type_id = Type.find_by_name(type) ? Type.find_by_name(type).id : Type.create(:name => type).id
  #         RestaurantType.create(:type_id => type_id, :restaurant_id => restaurant_id)
  #     end
  #   end
  #   
  end
         
  # Dishes   
  dish_sheet = parser.sheets[1]
  3.upto(parser.last_row(dish_sheet)) do |line|

    # Prepare data
    network = parser.cell(line,'B', dish_sheet).capitalize_first_letter.gsub(/^\p{Space}+|\p{Space}+$/, "") if parser.cell(line,'B', dish_sheet)
    dish_network_id = Network.find_by_name(network) ? Network.find_by_name(network).id : 0
    name = parser.cell(line,'D', dish_sheet).strip.gsub(/'\s|\s'|[“”‛’»«`]/, '"') if parser.cell(line,'D', dish_sheet)
    
    dish_category = parser.cell(line,'C', dish_sheet).downcase.gsub(/^\p{Space}+|\p{Space}+$/, "") if parser.cell(line,'C', dish_sheet)
    dish_category_id = DishCategory.find_by_name(dish_category) ? DishCategory.find_by_name(dish_category).id : DishCategory.create(:name => dish_category).id

    dish_type = parser.cell(line,'G', dish_sheet).downcase.gsub(/^\p{Space}+|\p{Space}+$/, "") if parser.cell(line,'G', dish_sheet)
    dish_type_id = DishType.find_by_name(dish_type) ? DishType.find_by_name(dish_type).id : DishType.create(:name => dish_type).id

    dish_extratype = parser.cell(line,'J', dish_sheet).downcase.gsub(/^\p{Space}+|\p{Space}+$/, "") if parser.cell(line,'J', dish_sheet)
    dish_extratype_id = DishExtratype.find_by_name(dish_extratype) ? DishExtratype.find_by_name(dish_extratype).id : DishExtratype.create(:name => dish_extratype).id

    photo_file = parser.cell(line,'H',dish_sheet) ? directory + parser.cell(line,'H',dish_sheet) : ''
    photo = File.open(photo_file) if File.file?(photo_file)

    description = parser.cell(line,'E', dish_sheet).gsub(/'\s|\s'|[“”‛’»«`]/, '"').strip if parser.cell(line,'E', dish_sheet)

    # dish = Dish.new
    #   dish.name = name
    #   dish.photo = photo
    #   dish.price = parser.cell(line,'F', dish_sheet)
    #   dish.description = description
    #   dish.dish_category_id = dish_category_id
    #   dish.dish_type_id = dish_type_id
    #   dish.network_id = dish_network_id
    #   dish.dish_subtype_id = 0
    #   dish.dish_extratype_id = dish_extratype_id
    # dish.save

    dish_data = {:name => name,
     :photo => photo,
     :price => parser.cell(line,'F', dish_sheet),
     :description => description,
     :dish_category_id => dish_category_id,
     :dish_type_id => dish_type_id,
     :network_id => dish_network_id,
     :dish_subtype_id => 0,
     :dish_extratype_id => dish_extratype_id
    }
    # puts dish_data if dish_data[:name].blank?
    Dish.create(dish_data) unless dish_data[:name].blank?
  end
end
