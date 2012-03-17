# encoding: utf-8
namespace :mi do
  
  task :update => :environment do
  
    require 'rubygems'
    require 'net/http'
    require 'uri'
    require 'builder'
    require 'xmlsimple'
    
    endpoint = 'http://188.93.18.50/MenutkaSoap/MenutkaSoapService.svc'
    soap = 'http://schemas.xmlsoap.org/soap/envelope/'
    service =  'http://www.w3.org/2002/ws/databinding/examples/6/05/'
    operation = "http://menutka.com/IMenutka/FilterRestaurants"
  
    lat_msk = '55.75354846578458'
    lng_msk = '37.60923964756874'

    lat_spb = '59.95378662114677'
    lng_spb = '30.31354584753765'
  
    module Net
      module HTTPHeader
        def x( k )
          return "SOAPAction" if k == 'soapaction'
          k.split(/-/).map {|i| i.capitalize }.join('-')
        end
      end
    end
  
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host)
    
    # Update Resturants Names    
    operation = "FilterRestaurants"
  
    req_headers= {
      'Content-Type' => 'text/xml; charset=utf-8',
      'User-Agent' => 'wsdl2objc',
      'Accept' => '*/*',
      'SOAPAction' => 'http://menutka.com/IMenutka/' + operation,
      'Connection' => 'keep-alive'
    }
  
    req_body_restaurants = "<?xml version=\"1.0\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
      <soap:Body>
        <tns1:FilterRestaurants>
          <tns1:filters>
            <tns2:Filter>
              <tns2:Id>4</tns2:Id>
              <tns2:NumericValues>
                <tns3:double>#{lat_spb}</tns3:double>
                <tns3:double>#{lng_spb}</tns3:double>
              </tns2:NumericValues>
              <tns2:Switcher>true</tns2:Switcher>
              <tns2:Type>3</tns2:Type>
            </tns2:Filter>
          </tns1:filters>
          <tns1:from>0</tns1:from>
          <tns1:to>9999</tns1:to>
        </tns1:FilterRestaurants>
      </soap:Body>
    </soap:Envelope>"
  
    response = http.request_post(uri.path, req_body_restaurants, req_headers).body.force_encoding("UTF-8")
    data = XmlSimple.xml_in(response, {'KeyAttr' => 'name'})
    restaurants = data['Body'][0]["#{operation}Response"][0]["#{operation}Result"][0]['Restaurant']
  
    restaurants.each do |r|
    
      data = {
        :address => r['Address'][0],
        :description => r['Description'][0],
        :dishes => r['Dishes'][0],
        :mi_id => r['Id'][0],
        :latitude => r['Latitude'][0],
        :longitude => r['Longitude'][0],
        :metro => r['Metro'][0],
        :name => r['Name'][0],
        :picture => r['PictureIds'],
        :site => r['Site'][0],
        :telephone => r['Telephone'][0],
        :wifi => r['WiFi'][0],
        :worktime => r['WorkTime'][0],
        :city => 'SPB'
      }    
      restaurant = MiRestaurant.find_by_mi_id(data[:mi_id])

      if restaurant.blank?

        # Get Dishes    
        operation3 = "GetRestaurantMenu"
        operation4 = "GetDishesDetails"

        r = MiRestaurant.create(data)

          req_body_dishes3 = "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
            <soap:Body>
              <tns1:#{operation3}>
                <tns1:restaurantId>#{r.mi_id}</tns1:restaurantId>
                <tns1:userId>1764</tns1:userId>
              </tns1:#{operation3}>
            </soap:Body>
          </soap:Envelope>"

          req_headers= {
            'Content-Type' => 'text/xml; charset=utf-8',
            'User-Agent' => 'wsdl2objc',
            'Accept' => '*/*',
            'SOAPAction' => 'http://menutka.com/IMenutka/' + operation3,
            'Connection' => 'keep-alive'
          }

          response = http.request_post(uri.path, req_body_dishes3, req_headers).body.force_encoding("UTF-8")
          data = XmlSimple.xml_in(response, {'KeyAttr' => 'name'})

          begin        
            ids = []
            dishes = data['Body'][0]["#{operation3}Response"][0]["#{operation3}Result"][0]['MenuItem']
            dishes.each do |d|
               ids.push("<tns2:int>#{d['Id'][0]}</tns2:int>")
             end

            req_body_dishes4 = "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
              <soap:Body>
                <tns1:GetDishesDetails>
                  <tns1:dishIds>
                    #{ids.join}
                  </tns1:dishIds>
                </tns1:GetDishesDetails>
              </soap:Body>
            </soap:Envelope>"

            req_headers= {
              'Content-Type' => 'text/xml; charset=utf-8',
              'User-Agent' => 'wsdl2objc',
              'Accept' => '*/*',
              'SOAPAction' => 'http://menutka.com/IMenutka/' + operation4,
              'Connection' => 'keep-alive'
            }

            response = http.request_post(uri.path, req_body_dishes4, req_headers).body.force_encoding("UTF-8")
            data = XmlSimple.xml_in(response, { 'KeyAttr' => 'name' })

            begin
              dishes = data['Body'][0]["#{operation4}Response"][0]["#{operation4}Result"][0]['Dish']
              dishes.each do |d|
                  data = {
                       :category_id => d['Category'][0]['Id'][0],
                       :category_name => d['Category'][0]['Name'][0],
                       :category_picture => d['Category'][0]['PictureId'][0],
                       :description => d['Description'][0],
                       :mi_id => d['Id'][0],
                       :kilo_calories => d['KKal'][0],
                       :cousine => d['Kitchens'][0],
                       :latitude => d['Latitude'][0],
                       :longitude => d['Longitude'][0],
                       :likes => d['Likes'][0],
                       :name => d['Name'][0],
                       :pictures => d['PictureIds'][0]['int'],
                       :price => d['Price'][0],
                       :restaurant_id => d['Restaurant'][0]['Id'][0],
                       :restaurant_name => d['Restaurant'][0]['Name'][0],
                       :composition => d['Sostav'][0],
                       :vegetarian => d['Vegas'][0],
                       :weight => d['Weight'][0]
                  }

                 unless MiDish.select(:mi_id).find_by_mi_id(data[:mi_id])
                   MiDish.create(data)
                   p "#{data[:mi_id]} - #{data[:name]}, at #{data[:restaurant_name]} YES!"
                 else
                   p "#{data[:mi_id]} ALREADY EXIST!"
                 end
              end
              p "#{r.mi_id} ok!"
            rescue
              p "#{i} NOT EXIST!"
            end

          rescue
            p "#{r.mi_id} err!"
          end
        end
    end
  end
  
  task :not_found => :environment do
    require 'csv'
    log_file_path = File.dirname(__FILE__).sub('/lib/tasks', '') + "/log/#{Time.new.strftime("%F-%H_%M_%S")}_mi_copy.log"
    
    MiRestaurant.where(:city => 'MSK').each do |mi_r|
      
      mi_name = mi_r.name.gsub(/^\p{Space}+|\p{Space}+$/, "")
      if n = Network.find_by_name(mi_name)
        n
      elsif r = Restaurant.find_by_name_eng(mi_name)
        r
      elsif n = Network.find_by_name(mi_name.gsub('.', ""))
        n
      elsif r = Restaurant.find_by_name(mi_name)
        r
      else
        
        p "#{mi_r.mi_id} #{mi_r.name} NOT FOUND IN DB"
        CSV.open(log_file_path, "a") do |csv|
          csv << ["#{mi_r.mi_id};#{mi_r.name};#{mi_r.address}"]
        end
      end
    end
    %x{iconv -t cp1251 #{log_file_path}  > #{log_file_path}.csv} if File.file?(log_file_path)
  end
  
  task :copy, [:file_for_fix] => :environment do |t, args|
    
    require 'csv'
    log_file_path = File.dirname(__FILE__).sub('/lib/tasks', '') + "/log/#{Time.new.strftime("%F-%H_%M_%S")}_mi_copy.log"
    
    mi_city = 'Saint Petersburg'
    mi_city_s = 'SPB'
    
    MiRestaurant.where(:city => mi_city_s).each do |mi_r|
      mi_name = mi_r.name.gsub(/^\p{Space}+|\p{Space}+$/, "")
      
      if args[:file_for_fix].nil?
         
        if n = Network.find_by_name_and_city(mi_name, mi_city)
          n = n
        elsif r = Restaurant.find_by_name_and_city(mi_name, mi_city)
          n = r.network
          n.name = r.name
          n.save
        elsif n = Network.find_by_name_and_city(mi_name.gsub('.', ""), mi_city)
          n.name = mi_r.name
          n.save
        elsif r = Restaurant.find_by_name_and_city(mi_name, mi_city)
          n = r.network
          n.name = r.name
          n.save
        elsif mi_city_s == 'SPB'
          n = Network.create({
            :name => mi_name,
            :city => mi_city
          })
        else
          p "#{mi_r.mi_id} #{mi_r.name} NOT FOUND IN DB"
          CSV.open(log_file_path, "a") do |csv|
            csv << ["#{mi_r.mi_id};#{mi_r.name}"]
          end
        end
        
      else  
        file = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/' + args[:file_for_fix]
        parser = Excelx.new(file, false, :ignore)
        
        2.upto(parser.last_row(dish_sheet)) do |line|
          if mi_r.mi_id.to_i == parser.cell(line,'A').to_i
            
            if parser.cell(line,'D') != 'delete'
              if parser.cell(line,'D') == 'add resto'
                
                n = Network.create({
                  :name => mi_name,
                  :city => mi_city
                })
                
              else 
                n = Network.find_by_id(parser.cell(line,'D').to_i)
              end
              
            end
          end          
        end
      end
      
      if n && n.dishes.count < 15
        p "#{n.id} #{n.name}"
      
        if n.dishes.count == 0
          n.restaurants.each {|rest| rest.destroy}
        else
          n.restaurants.each do |r_del|
            r_del.destroy if r_del.reviews.count == 0
          end
        end

        MiRestaurant.where(:name => mi_r.name, :city => mi_city_s).each do |mi_ar|
          restaurant_data = {
            :name => mi_ar.name.capitalize_first_letter,
            :address => mi_ar.address,
            :time => mi_ar.worktime,
            :phone => mi_ar.telephone,
            :description => mi_ar.description,
            :web => mi_ar.site,
            :lat => mi_ar.latitude,
            :lon => mi_ar.longitude,
            :network_id => n.id,
            :wifi => mi_ar.wifi || 0,
            :station => mi_ar.metro,
            :source => 'web_mi_u2',
            :city => mi_city
          }
          
          r = Restaurant.create(restaurant_data)
          mi_ar.step = 11
          mi_ar.save
          p "--- #{mi_ar.address}"
          
        end

        i = 0
        dish_category_id_new = 0
        restaurant_id_new = 0
        MiDish.where(:restaurant_id => mi_r.mi_id).each do |mi_d|
        
          dc_name = mi_d.category_name.downcase.gsub(/^\p{Space}+|\p{Space}+$/, "")
          dish_category_id = DishCategory.find_by_name(dc_name) ? DishCategory.find_by_name(dc_name).id : DishCategory.create(:name => dc_name).id

          types = {'1' => 14, '10' => 16, '11' => 15, '13' => 18, '14' => 15, '16' => 18, '17' => 2, '18' => 15,
            '2' => 4, '20' => 17, '3' => 15, '4' => 15, '5' => 15, '594' => 15, '6' => 15, '6906' => 2, '6907' => 2,
            '6961' => 7, '7' => 2, '8' => 14, '9' => 15
          }
    
          sub_types = {'11' => 13, '17' => 28, '18' => 21, '3' => 46, '4' => 7, '5' => 11, '594' => 4, '6' => 19,
            '6907' => 27, '9' => 5
          }
        
          dish_data = {
            :name => mi_d.name,
            :remote_photo_url => mi_d.pictures.blank? ? nil : "http://188.93.18.50/menutka/GetImageMedium/#{mi_d.pictures[/"([\d]+)"/, 1]}.jpg",
            :price => mi_d.price,
            :description => mi_d.description['--- {}'].nil? ? mi_d.description : nil,
            :network_id => n.id,

            :dish_category_id => dish_category_id,
            :dish_type_id => types[mi_d.category_id],
            :dish_subtype_id => sub_types[mi_d.category_id],
            :dish_extratype_id => mi_d.vegetarian == 'true' ? 4 : nil,
          }
        
          unless Dish.find_by_name_and_network_id(dish_data[:name], dish_data[:network_id])
            Dish.create(dish_data)
            p "    --- #{mi_d.name}"  
          
            # Set Dish Category Order
            if dish_category_id_new != dish_category_id
              i += 1
              Restaurant.where(:network_id => r.network_id).each do |r|
                dish_category_order_data = {
                  :restaurant_id => r.id,
                  :network_id => r.network_id,
                  :dish_category_id => dish_category_id,
                  :order => i
                }

                DishCategoryOrder.create(dish_category_order_data)
                dish_category_id_new = dish_category_id
                restaurant_id_new = r.id
              end
            end
          end

          MiRestaurant.where(:name => mi_r.name).each do |mi_ar|
            mi_ar.step = 12
            mi_ar.save
          end
        
        end
      end
    end
  end
  
end
