# encoding: utf-8
namespace :import do
  
  desc "Set categories for Dishes" 
  task :set_categoies, [:dirname, :filename] => :environment do |t, args|
    require 'csv'
    
    t = Time.new
    i = 0
    directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/' + args[:dirname] + '/'
    log_file_path = File.dirname(__FILE__).sub('/lib/tasks', '') + "/log/import/#{t.strftime("%F-%H_%M_%S")}_excel_export.log"
    file = directory + args[:filename]
    parser = Excelx.new(file, false, :ignore)  
    dish_sheet = parser.sheets[1]
    network_chk = String
    dish_category_chk = String
    
    3.upto(parser.last_row(dish_sheet)) do |line|         
        network_name = parser.cell(line,'B', dish_sheet).capitalize_first_letter.gsub(/^\p{Space}+|\p{Space}+$/, "") if parser.cell(line,'B', dish_sheet)
        dish_category_name = parser.cell(line,'C', dish_sheet).downcase.gsub(/^\p{Space}+|\p{Space}+$/, "") if parser.cell(line,'C', dish_sheet)
        if parser.cell(line,'C', dish_sheet) != dish_category_chk
            i += 1
            if dish_category = DishCategory.find_by_name(dish_category_name)
                if dish_network =  Network.find_by_name(network_name)
                      dish_network.restaurants.each do |r|
                          unless DishCategoryOrder.find_by_dish_category_id_and_restaurant_id(dish_category.id, r.id)
                              p dish_category.name + " : " + r.name.to_s + " " + r.address.to_s
                              DishCategoryOrder.create({
                                :dish_category_id => dish_category.id,
                                :network_id => dish_network.id,
                                :restaurant_id => r.id,
                                :order => i
                              })
                            end
                      end
                      i += 0 if parser.cell(line,'B', dish_sheet) != network_chk
                      network_chk = parser.cell(line,'B', dish_sheet)
                end
            end
            dish_category_chk = parser.cell(line,'C', dish_sheet)
        end
    end
  
  end
  
  desc "Check if all images in a place" 
  task :check_images, [:dirname, :filename] => :environment do |t, args|
    
    require 'csv'
    
    t = Time.new
    directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/' + args[:dirname] + '/'
    log_file_path = File.dirname(__FILE__).sub('/lib/tasks', '') + "/log/import/#{t.strftime("%F-%H_%M_%S")}_excel_export.log"
    file = directory + args[:filename]
    parser = Excelx.new(file, false, :ignore)  
    dish_sheet = parser.sheets[1]
    
    3.upto(parser.last_row) do |line|
      photo_file = parser.cell(line,'K') ? directory + parser.cell(line,'B') + '/' + parser.cell(line,'K') : ''            
      if !File.file?(photo_file) && !photo_file.blank?
        CSV.open(log_file_path, "a") do |csv|
          csv << ["#{Time.now};file #{photo_file} not found for #{parser.cell(line,'B')} at #{parser.cell(line,'B')}"]
        end
      end
    end
    
    3.upto(parser.last_row(dish_sheet)) do |line|
      photo_file = parser.cell(line,'H',dish_sheet) ? directory + parser.cell(line,'B', dish_sheet) + '/' + parser.cell(line,'H',dish_sheet) : ''
      if !File.file?(photo_file) && !photo_file.blank?
        CSV.open(log_file_path, "a") do |csv|
          csv << ["#{Time.now};file #{photo_file} not found for #{parser.cell(line,'D', dish_sheet)} at #{parser.cell(line,'B', dish_sheet)}"]
        end
      end
    end
    
    sep = '==========================================================='
    p sep
    if File.file?(log_file_path)
      %x{iconv -t cp1251 #{log_file_path}  > #{log_file_path}.csv}
      p "Done. There are some errors, log file is here: #{log_file_path}.csv"
      %x{open #{log_file_path}.csv}
    else
      p "Done. Congrats, no errors!"
    end
    p sep
  end
  
  desc "Import excel file" 
  task :xls, [:dirname, :filename] => :environment do |t, args|
  
    require 'csv'
  
    directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/' + args[:dirname] + '/'
    log_file_path = File.dirname(__FILE__).sub('/lib/tasks', '') + "/log/import/#{Time.new.strftime("%F-%H_%M_%S")}_excel_export.log"
    file = directory + args[:filename]
    parser = Excelx.new(file, false, :ignore)  
    restaurant_chk = String
        
    3.upto(parser.last_row) do |line|
   
      # Delete Existed
      if parser.cell(line,'B') != restaurant_chk
       if network = Network.find_by_name(parser.cell(line,'B'))
         network.restaurants.each do |r|
            if r.reviews.count < 1
              r.restaurant_images.each do |i| 
                p i.id.to_s + ' image exist'
                p i.id.to_s + ' image deleted' if i.destroy
              end
              p "try to delete #{r.id} : #{r.name}"
              p "succ. deleted #{r.id} : #{r.name}" if r.destroy
            else
              p "#{r.id} : #{r.name} #{r.address} has 1 or more reviews"
            end
         end
         network.dishes.each do |d| 
           if d.reviews.count < 1
             p "try to delete #{d.id} : #{d.name}"
             p "succ. deleted #{d.id} : #{d.name}" if d.destroy
           else
             p "#{d.id} : #{d.name} has 1 or more reviews"
           end
         end
         restaurant_chk = parser.cell(line,'B')
       end
      end
      
      # Prepare data
      network = parser.cell(line,'B').capitalize_first_letter.gsub(/^\p{Space}+|\p{Space}+$/, "")
      network_id = Network.find_by_name(network) ? Network.find_by_name(network).id : Network.create(:name => network).id
      photo_file = parser.cell(line,'K') ? directory + parser.cell(line,'B') + '/' + parser.cell(line,'K') : ''            
    
      if File.file?(photo_file)
        photo = File.open(photo_file) 
      elsif (!photo_file.blank?)
        CSV.open(log_file_path, "a") do |csv|
          csv << ["#{Time.now};file #{photo_file} not found for #{parser.cell(line,'B')} at #{parser.cell(line,'B')}"]
        end
      end
  
      restaurant_data = {
        :name => parser.cell(line,'B').capitalize_first_letter,
        :city => parser.cell(line,'C').blank? ? '' : parser.cell(line,'C').strip.gsub(/г\./, ''),
        :address => parser.cell(line,'E'),
        :time => parser.cell(line,'G'),
        :phone => parser.cell(line,'F'),
        :web => parser.cell(line,'J'),
        :breakfast => parser.cell(line,'P'),
        :businesslunch => parser.cell(line,'O'),
        :network_id => network_id,
        :wifi => parser.cell(line,'L') || 0,
        :chillum => parser.cell(line,'M') || 0,
        :terrace => parser.cell(line,'N') || 0,
        :cc => parser.cell(line,'Q') || 0,
        :source => 'new_xlst',
        :sun => parser.cell(line,'Y'),
        :mon => parser.cell(line,'S'),
        :tue => parser.cell(line,'T'),
        :wed => parser.cell(line,'U'),
        :thu => parser.cell(line,'V'),
        :fri => parser.cell(line,'W'),
        :sat => parser.cell(line,'X'),
      }
    
      # Create
      unless restaurant_data[:name].blank?
  
        unless parser.cell(line,'A').blank?
          if restaurant = Restaurant.find_by_id(parser.cell(line,'A').to_i)
            restaurant.update_attributes(restaurant_data)
            restaurant_id = restaurant.id
          else
            restaurant_id = Restaurant.create(restaurant_data).id
          end
        else
          restaurant_id = Restaurant.create(restaurant_data).id
        end
  
        unless restaurant_id.blank?
          RestaurantImage.create(:photo => photo, :restaurant_id => restaurant_id)

          parser.cell(line,'I').split(',').each do |cuisine|
             cuisine.downcase!.gsub!(/^\p{Space}+|\p{Space}+$/, "")
             cuisine_id = Cuisine.find_by_name(cuisine) ? Cuisine.find_by_name(cuisine).id : Cuisine.create(:name => cuisine).id
             RestaurantCuisine.create(:cuisine_id => cuisine_id, :restaurant_id => restaurant_id)
          end

          parser.cell(line,'H').split(',').each do |type|
             type.downcase!.gsub!(/^\p{Space}+|\p{Space}+$/, "")
             type_id = Type.find_by_name(type) ? Type.find_by_name(type).id : Type.create(:name => type).id
             RestaurantType.create(:type_id => type_id, :restaurant_id => restaurant_id)
          end
          p restaurant_id.to_s + ' : ' + restaurant_data[:name] + ' : ' + restaurant_data[:address]
        end
      end
            
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
  
      photo_file = parser.cell(line,'H',dish_sheet) ? directory + parser.cell(line,'B', dish_sheet) + '/' + parser.cell(line,'H',dish_sheet) : ''
    
      if File.file?(photo_file)
        photo = File.open(photo_file) 
      elsif (!photo_file.blank?)
        CSV.open(log_file_path, "a") do |csv|
          csv << ["#{Time.now};file #{photo_file} not found for #{parser.cell(line,'D', dish_sheet)} at #{parser.cell(line,'B', dish_sheet)}"]
        end
      end
    
      description = parser.cell(line,'E', dish_sheet).to_s.gsub(/'\s|\s'|[“”‛’»«`]/, '"').strip if parser.cell(line,'E', dish_sheet)
    
      dish_data = {
        :name => name,
        :photo => photo,
        :price => parser.cell(line,'F', dish_sheet),
        :description => description,
        :dish_category_id => dish_category_id,
        :dish_type_id => dish_type_id,
        :network_id => dish_network_id,
        :dish_subtype_id => 0,
        :dish_extratype_id => dish_extratype_id
      }
    
      # Create
      unless dish_data[:name].blank?
        unless parser.cell(line,'A', dish_sheet).blank?
          if dish = Dish.find_by_id(parser.cell(line,'A', dish_sheet).to_i)
            dish.update_attributes(dish_data)
            dish_id = dish.id
          else
            dish_id = Dish.create(dish_data).id unless Dish.find_by_name(dish_data[:name])
          end
        else
          dish_id = Dish.create(dish_data).id unless Dish.find_by_name(dish_data[:name])
        end
      end
    
      p dish_id.to_s + ' : ' + dish_data[:name] unless dish_id.blank?

    end
    
    sep = '==========================================================='
    p sep
    if File.file?(log_file_path)
      %x{iconv -t cp1251 #{log_file_path}  > #{log_file_path}.csv}
      p "Done. There are some errors, log file is here: #{log_file_path}.csv"
      %x{open #{log_file_path}.csv}
    else
      p "Done. Congrats, no errors!"
    end
    p sep
  end
end
