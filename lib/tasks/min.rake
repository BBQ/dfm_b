# encoding: utf-8
namespace :mi do
  
  task :group => :environment do
    
    unless MiRestaurant.select(:network_id).order("network_id DESC").limit(1).blank?
      i = MiRestaurant.select(:network_id).order("network_id DESC").first.network_id + 1
    else
      i = 1
    end
    st = 0
    
    MiRestaurant.select([:mi_id, :name, :id]).order(:mi_id).where("network_id IS NULL AND city = 'MSK'").each do |r|
      
      p "CHECKIN: #{r.mi_id} - #{r.name}"
      restaurant_1 = MiRestaurant.select([:mi_id, :name, :id, :network_id]).find_by_mi_id(r.mi_id)
      
      if restaurant_1.network_id.nil? 
        
        restaurant_1.network_id = i
        r_dishes = MiDish.select(:name).where("restaurant_id = ? AND category_id != 13 AND category_id != 16", r.mi_id)
      
        MiRestaurant.select([:mi_id, :name, :id]).order('id DESC').where("city = 'MSK' AND name = ?", r.name).each do |tr|
          MiDish.select(:name).where("restaurant_id = ? AND category_id != 13 AND category_id != 16", tr.mi_id).each do |tr_d|
          
            st = 0
            r_dishes.each do |r_d|
              if tr_d.name == r_d.name
                st = 1
                break
              end
            end
            if st == 0
              i += 1
              break
            end
          
          end
        
          restaurant_2 = MiRestaurant.select([:mi_id, :name, :id, :network_id]).find_by_mi_id(tr.mi_id)
          
          if restaurant_2.network_id.nil?
            restaurant_2.network_id = i
          else 
            restaurant_1.network_id = restaurant_2.network_id
            i = restaurant_2.network_id
          end
          
          if restaurant_1.network_id != restaurant_2.network_id
            p "#{tr.mi_id} - #{tr.name} is not like #{r.mi_id} - #{r.name}"
            restaurant_2.step = 2
          else
            p "#{tr.mi_id} - #{tr.name} is same with #{r.mi_id} - #{r.name}"
          end
          
          restaurant_1.save
          restaurant_2.save
          
        end
      end
      i += 1
    end 
  end
  
  task :parse, [:type] => :environment do |t, args|
  
    require 'rubygems'
    require 'net/http'
    require 'uri'
    require 'builder'
    require 'xmlsimple'
  
    type = args[:type] ||= 'dishes'
  
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
  
    # Get Resturants
    if type == 'restaurants'
    
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
                  <tns3:double>#{lat_msk}</tns3:double>
                  <tns3:double>#{lng_msk}</tns3:double>
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
      
        unless MiRestaurant.find_by_mi_id(data[:mi_id])
          MiRestaurant.create(data)
          p "#{data[:name]}, #{data[:address]} YES!"
        else
          p "#{data[:mi_id]} ALREADY EXIST!"
        end
      end  
    end
  
    # Get Dishes
    if type == 'dishes'
    
      operation3 = "GetRestaurantMenu"
      operation4 = "GetDishesDetails"
    
      MiRestaurant.select(:mi_id).where('id > 1733').order(:id).each do |r|
    
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
        data = XmlSimple.xml_in(response, { 'KeyAttr' => 'name' })
    
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
end
