# encoding: utf-8
namespace :ylp do
  
  require 'oauth'
  require 'json'
  require 'net/http'
  require 'open-uri'
  require 'nokogiri'
  require 'time'
  require 'cgi'
  
  task :recov_cat => :environment do
    fill_4sq_with_yel
  end
  
  task :fill_4sq_with_yel => :environment do
    fill_4sq_with_yel
  end

  task :time_zone => :environment do
    WorkHour.all.each do |wh|
      wh.time_zone_offset = Restaurant.find_by_id(wh.restaurant_id).time_zone_offset
      p wh.time_zone_offset
      wh.save
    end
  end
  
  task :work_hour_c => :environment do
    Restaurant.select([:id, :name, :lat, :lon]).where(:source => 'ylp').each do |r|
      
      if yr = YlpRestaurant.select(:hours).find_by_name_and_lat_and_lng(r.name, r.lat, r.lon)
        if yr.hours
          f_hours(yr.hours).each do |h|
            h[:restaurant_id] = r.id
            puts h
            WorkHour.create(h)
          end
        end
      end
    end
  end
  
  task :fix_menu_categories => :environment do

    all_r = Restaurant.select([:id, :fsq_id, :network_id]).where(:source => 'ylp').order(:id)
    count = all_r.count
   
    p "Overall: #{count}"
    i = 0

    all_r.each do |r|
      if yr = YlpRestaurant.find_by_fsq_id_and_has_menu(r.fsq_id,1)

        r.dishes.all.each do |d|
          if yd = YlpDish.find_by_name_and_ylp_restaurant_id(d.name, yr.id)
          
            unless yd.dish_category.to_s.blank?
              if dish_category = DishCategory.find_by_name(yd.dish_category)
                d.dish_category_id = dish_category.id
              else
                d.dish_category_id = DishCategory.create({:name => yd.dish_category}).id
              end
              d.save      
            end
            
          end
        end
        
      end
      i += 1
      p "Done:#{r.id}, Left: #{count - i}"
      
    end
  end
  
  task :clean_rest => :environment do
    if rest_rev_ids = Review.select(:restaurant_id).group(:restaurant_id).all.collect {|r| r.restaurant_id}.compact.join(',')
      Restaurant.delete_all("id NOT IN (#{rest_rev_ids}) AND id > 17974 AND city NOT IN ('Москва', 'Moscow', 'Tallinn', 'Skolkovo', 'Tallinna')")
    end
    
    if netw_without_rest_ids = Network.select('networks.id').joins(:restaurants).group('networks.id').collect {|n| n.id}.compact.join(',')
      Network.delete_all("id not IN (#{netw_without_rest_ids})")
    end
    
    if dsh_without_rest_ids = Network.select('networks.id').joins(:restaurants).group('networks.id').collect {|n| n.id}.compact.join(',')
      Network.delete_all("id not IN (#{netw_without_rest_ids})")
    end
    
  end
  
  task :cl_ny => :environment do
    p Restaurant.where("source = 'ylp' AND created_at <= '2012-03-27 09:07:22'").delete_all 
    p YlpDish.where("created_at <= '2012-03-27 09:07:22'").delete_all  
    p YlpRestaurant.where("created_at <= '2012-03-27 09:07:22'").update_all("has_menu = NULL") 
  end
  
  task :review => :environment do
    i = 0
    rest = Restaurant.where("source ='foursquare'")
    
    rest.each do |r|
      if r1 = Restaurant.where("source = 'ylp' AND network_id = ? AND fsq_id = ?", r.network_id, r.fsq_id).first
        i += 1
      elsif r1 = Restaurant.where("source = 'ylp' AND network_id = ? AND address LIKE ?", r.network_id, "%#{r.address.gsub(/\.|,/, '')}%").first
        i += 1
      elsif r1 = Restaurant.where("source = 'ylp' AND network_id = ? AND ROUND(lat, 3) = ? AND ROUND(lon, 3) = ?", r.network_id, r.lat.round(3), r.lon.round(3)).first
        i += 1
      elsif r1 = Restaurant.where("source = 'ylp' AND network_id = ? AND phone = ? ", r.network_id, r.phone).first
        i += 1    
      else
        # p "#{r.id}; #{r.name}; #{r.address}; #{r.city};"
      end
      
      unless r1.nil?
        r.time = r1.time
        r.phone = r1.phone
        r.web = r1.web
        r.wifi = r1.wifi
        r.terrace = r1.terrace
        r.cc = r1.cc
        r.source = r1.source
        r.good_for_kids = r1.good_for_kids
        r.reservation = r1.reservation
        r.delivery = r1.delivery
        r.takeaway = r1.takeaway
        r.service = r1.service
        r.alcohol = r1.alcohol
        r.noise = r1.noise
        r.tv = r1.tv
        r.disabled = r1.disabled
        r.parking = r1.parking
        r.bill = r1.bill
        r.sun = r1.sun
        r.mon = r1.mon
        r.tue = r1.tue
        r.wed = r1.wed
        r.thu = r1.thu
        r.fri = r1.fri
        r.sat = r1.sat
        r.attire = r1.attire
        r.transit = r1.transit
        r.caters = r1.caters
        r.ambience = r1.ambience
        r.good_for_groups = r1.good_for_groups
        r.good_for_meal = r1.good_for_meal
        
        # r.save
        p "#{r.id} #{r.name} #{r.fsq_id} #{r.address} #{r.phone}"
        p "#{r1.id} #{r1.name} #{r1.fsq_id} #{r1.address} #{r1.phone}"
        # r1.destroy
      end
    end
    p "#{rest.count}/#{i}"
  end
  
  task :copy => :environment do
    id_start = 1
    id_end = 10000
    
    copy_restaurants(id_start,id_end)
  end
  
  task :update_yelp_with_fsq  => :environment do
    YlpRestaurant.where('id >=45000 && id < 50000 && fsq_id is NULL').order(:id).each do |r|
      p "#{r.id}: #{r.name} - #{r.address}"
      update_yelp_with_fsq(r)
    end
    p "Done!"
  end
  
  task :parse => :environment do
    parse
  end
  
end

def copy_restaurants(id_start, id_end)
  restaurants = YlpRestaurant.order('id')
  restaurants = restaurants.where("id > ? AND id <= ? AND has_menu = 1",id_start,id_end) if id_start > 0 && id_end > id_start
  
  restaurants.each do |r|
    data = collect_restaurant_data(r)
    
    p "#{r.id} #{r.name}"
    p " address: #{data[:address]}"     
    p " network: #{data[:network_id]}"
    
    if restaurant_existed = Restaurant.find_by_address_and_network_id(data[:address],data[:network_id])
      restaurant_existed.update_attributes(data)        
      if r.menu_copied == false
        clear_dishes(restaurant_existed)
        p copy_menu(restaurant_existed)
      end 
    else
      new_restaurant = Restaurant.create(data)
      p copy_menu(new_restaurant) if r.menu_copied == false
    end      
  end
  
end

def copy_menu(restaurant)
  if r_menu = YlpRestaurant.where("name = ? AND has_menu = 1", restaurant.name).first
    dish_category_id_old = 0
    i = 0
    
    r_menu.ylp_dishes.each do |yd|
      unless Dish.find_by_name_and_network_id(yd.name, restaurant.network_id)      
        dish_category = DishCategory.find_by_name(yd.dish_category) || DishCategory.create(:name => yd.dish_category)

        if dish_category_id_old != dish_category.id
          i += 1

          dish_category_order_data = {
            :network_id => restaurant.network_id,
            :dish_category_id => dish_category.id,
            :order => i
          }
          
          DishCategoryOrder.create(dish_category_order_data)
          dish_category_id_old = dish_category.id
        end
    
        data = {
          :network_id => restaurant.network_id,
          :name => yd.name,
          :price => yd.price ||= 0,
          :currency => yd.currency ||= '',
          :description => yd.description,
          :dish_category_id => dish_category.id,
          :fsq_checkins_count => restaurant.fsq_checkins_count
        }
        Dish.create(data)
      
      end
    end
    res = " menu copied to #{restaurant.network_id}"
  else
    res = " menu is empty"
  end
  YlpRestaurant.where("name = ?", restaurant.name).update_all(:menu_copied => true)
  res
end


def clear_dishes(restaurant_existed)
  if restaurant_existed.network.dishes.any?
    reviews = restaurant_existed.network.reviews.group(:dish_id).all
  
    if reviews.any?
      r_ids = []
      reviews.each {|rw| r_ids.push(rw.dish_id)}      
      restaurant_existed.network.dishes.where("id NOT IN (#{r_ids.join(',')})").destroy_all
    else
      restaurant_existed.network.dishes.destroy_all
    end
  
  end
end


def set_network_id(name, city)
  if n = Network.find_by_name_and_city(name, city)
    network_id = n.id
  elsif n = Network.create(:name => name, :city => city)
    network_id = n.id
  end
  network_id
end

def set_categories(restaurant)
  categories = []  
  cat = restaurant.category || restaurant.restaurant_categories
  
  unless cat.nil?
    cat.split(',').each do |name|
      
      if category = RestaurantCategory.find_by_name(name)
        categories.push(category.id)
      else
        categories.push(RestaurantCategory.create(:name => name).id)
      end
      
    end
  end
  categories.join(',')
end

def collect_restaurant_data(restaurant)
  
  if restaurant.cc == 'Yes'
    restaurant.cc = 1
  elsif restaurant.cc == 'No'
    restaurant.cc = 0
  end
  
  if restaurant.outdoor_seating == 'Yes'
    restaurant.outdoor_seating = 1
  elsif restaurant.outdoor_seating == 'No'
    restaurant.outdoor_seating = 0
  end
  
  if restaurant.delivery == 'Yes'
    restaurant.delivery = 1
  elsif restaurant.delivery == 'No'
    restaurant.delivery = 0
  end
  
  data = {}
  data = f_hours(restaurant.hours) unless restaurant.hours.nil?
  
  data[:network_id] = set_network_id(restaurant.name, restaurant.city)
  data[:address] = restaurant.address || restaurant.fsq_address
  
  data[:transit] = restaurant.transit
  data[:attire] = restaurant.attire
  data[:caters] = restaurant.caters
  data[:ambience] = restaurant.ambience

  data[:name] = restaurant.name
  data[:city] = restaurant.city

  data[:lon] = restaurant.lng
  data[:lat] = restaurant.lat
  data[:fsq_lng] = restaurant.fsq_lng || restaurant.fsq_lng
  data[:fsq_lat] = restaurant.fsq_lat || restaurant.fsq_lat
  data[:phone] = restaurant.phone
  data[:web] = restaurant.web             

  data[:wifi] = restaurant.wifi
  data[:terrace] = restaurant.outdoor_seating
  data[:cc] = restaurant.cc
  data[:source] = 'ylp'
  data[:time] = restaurant.hours

  data[:reservation] = restaurant.reservation
  data[:delivery] = restaurant.delivery
  data[:takeaway] = restaurant.takeout
  data[:service] = restaurant.table_service
  data[:good_for_kids] = restaurant.kids
  data[:good_for_meal] = restaurant.meal
  data[:good_for_groups] = restaurant.groups
  data[:alcohol] = restaurant.alcohol
  data[:noise] = restaurant.noise
  data[:tv] = restaurant.tv
  data[:disabled] = restaurant.wheelchair_accessible
  data[:parking] = restaurant.parking
  data[:bill] = restaurant.price
  data[:fsq_checkins_count] = restaurant.fsq_checkins_count
  data[:fsq_tip_count] = restaurant.fsq_tip_count
  data[:fsq_users_count] = restaurant.fsq_users_count
  data[:fsq_name] = restaurant.fsq_name
  data[:fsq_address] = restaurant.fsq_address
  data[:fsq_id] = restaurant.fsq_id
  data[:restaurant_categories] = set_categories(restaurant)
  
  data
end

def update_yelp_with_fsq(r)
  begin
    client = Foursquare2::Client.new(:client_id => $client_id, :client_secret => $client_secret)  
    
    if r.fsq_id.nil?
      if r.lat && r.lng && r.name 
        
        if fsq_hash = client.search_venues(:ll => "#{r.lat},#{r.lng}", :query => r.name, :intent => 'checkin')    
          if fsq_hash.groups[0].items.any?
            
            if fsq_r = match_yelp_and_fsq_restaurants(r,fsq_hash)
              update_yelp_restaurant_with_fsq_info!(r, fsq_r)
            end
            
          end
        end    
        
      end
    end
    update_yelp_restaurant_with_fsq_menu!(r,client) if !r.fsq_id.nil? && r.has_menu == false
    
  rescue Exception => e
    p e.message
    update_yelp_with_fsq(r)
  end
end

def match_yelp_and_fsq_restaurants(r,fsq_hash)
  fsq_r = nil
  
  fsq_hash.groups[0].items.each {|i| fsq_r = i if i.downcase == r.name.downcase}        
  fsq_hash.groups[0].items.each {|i| fsq_r = i if i.contact.formattedPhone.to_s == r.phone.to_s} if fsq_r.nil?  
  fsq_hash.groups[0].items.each {|i| fsq_r = i if i.name.to_s =~ /#{r.name}/} if fsq_r.nil?
  
  fsq_r
end

def update_yelp_restaurant_with_fsq_info!(r,fsq_r)
  category = []
  fsq_r.categories.each {|v| category.push(v.name)}

  r.fsq_id = fsq_r.id        
  r.fsq_name = fsq_r.name
    
  r.fsq_address = fsq_r.location.address
  r.fsq_lat = fsq_r.location.lat
  r.fsq_lng = fsq_r.location.lng
  
  r.fsq_checkins_count = fsq_r.stats.checkinsCount
  r.fsq_users_count = fsq_r.stats.usersCount
  r.fsq_tip_count = fsq_r.stats.tipCount
  
  r.restaurant_categories = category.count > 0 ? category.join(',') : 0
  r.has_menu = 0
  
  r.save  
  p " found #{r.fsq_id}: #{r.fsq_name} - #{r.fsq_address}"
end

def update_yelp_restaurant_with_fsq_menu!(r,client)
  client.venue_menu(r.fsq_id).each do |m| 

    m.entries.fourth.second.items.each do |i|
      i.entries.third.second.items.each do |d|  

        if d.prices
          if price = /(.)(\d+\.\d+)/.match(d.prices.first)
            price = price[2]
            currency = /(.)(\d+\.\d+)/.match(d.prices.first)[1]
          else
            price = /(.)(\d+\.\d+)/.match(d.prices.second)[2]
            currency = /(.)(\d+\.\d+)/.match(d.prices.second)[1]
          end
        end

        data = {
        :ylp_restaurant_id => r.id,
        :name => d.name,
        :price => price ||= 0,
        :currency => currency ||= '',
        :description => d.description,
        :dish_category => i.name,
        }
        
        YlpDish.create(data) unless YlpDish.find_by_name_and_ylp_restaurant_id(d.name, r.id)
        
      end
    end
    r.has_menu = 1
    r.save
    p " menu found"
    
  end
end

def parse
  
  # New York
   manhattan = "Alphabet_City,Battery_Park,Chelsea,Chinatown,Civic_Center,East_Harlem,East_Village,Financial_District,Flatiron,Gramercy,Greenwich_Village,Harlem,Hell's_Kitchen,Inwood,Kips_Bay,Koreatown,Little_Italy,Lower_East_Side,Manhattan_Valley,Marble_Hill,Meatpacking_District,Midtown_East,Midtown_West,Morningside_Heights,Murray_Hill,NoHo,Nolita,Roosevelt_Island,SoHo,South_Street_Seaport,South_Village,Stuyvesant_Town,Theater_District,TriBeCa,Two_Bridges,Union_Square,Upper_East_Side,Upper_West_Side,Washington_Heights,West_Village,Yorkville"
   brooklyn = "Bath_Beach,Bay_Ridge,Bedford_Stuyvesant,Bensonhurst,Boerum_Hill,Borough_Park,Brighton_Beach,Brooklyn_Heights,Brownsville,Bushwick,Canarsie,Carroll_Gardens,City_Line,Clinton_Hill,Cobble_Hill,Columbia_Street_Waterfront_District,Coney_Island,Crown_Heights,Cypress_Hills,DUMBO,Ditmas_Park,Downtown_Brooklyn,Dyker_Heights,East_Flatbush,East_New_York,East_Williamsburg,Flatbush,Flatlands,Fort_Greene,Fort_Hamilton,Georgetown,Gerritson_Beach,Gowanus,Gravesend,Greenpoint,Highland_Park,Kensington,Manhattan_Beach,Marine_Park,Midwood,Mill_Basin,Mill_Island,New_Lots,Ocean_Hill,Ocean_Parkway,Paedergat_Basin,Park_Slope,Prospect_Heights,Prospect_Lefferts_Gardens,Prospect_Park_South,Red_Hook,Remsen_Village,Sea_Gate,Sheepshead_Bay,South_Williamsburg,Spring_Creek,Starret_City,Sunset_Park,Vinegar_Hill,Weeksville,Williamsburg_-_North_Side,Williamsburg_-_South_Side,Windsor_Terrace,Wingate"
   queens = "Arverne,Astoria,Astoria_Heights,Auburndale,Bay_Terrace,Bayside,Beechurst,Bellaire,Belle_Harbor,Bellerose,Breezy_Point,Briarwood,Cambria_Heights,College_Point,Douglaston,Downtown_Flushing,East_Elmhurst,Edgemere,Elmhurst,Far_Rockaway,Floral_Park,Flushing,Flushing_Meadows,Forest_Hills,Fresh_Meadows,Glen_Oaks,Glendale,Hillcrest,Hollis,Holliswood,Howard_Beach,Hunters_Point,JFK_Airport,Jackson_Heights,Jamaica,Jamaica_Estates,Jamaica_Hills,Kew_Gardens,Kew_Gardens_Hills,LaGuardia_Airport,Laurelton,LeFrak_City,Lindenwood,Little_Neck,Long_Island_City,Malba,Maspeth,Middle_Village,Murray_Hill,North_Corona,Oakland_Gardens,Ozone_Park,Pomonok,Queens_Village,Queensborough_Hill,Rego_Park,Richmond_Hill,Ridgewood,Rochdale,Rockaway_Park,Rosedale,Seaside,Somerville,Springfield_Gardens,Steinway,Sunnyside,Utopia,Whitestone,Woodhaven,Woodside"
   bronx = "Baychester,Bedford_Park,Belmont,Castle_Hill,City_Island,Claremont_Village,Clason_Point,Co-op_City,Concourse,Concourse_Village,Country_Club,East_Tremont,Eastchester,Edenwald,Edgewater_Park,Fieldston,Fordham,High_Bridge,Hunts_Point,Kingsbridge,Longwood,Melrose,Morris_Heights,Morris_Park,Morrisania,Mott_Haven,Mount_Eden,Mount_Hope,North_Riverdale,Norwood,Olinville,Parkchester,Pelham_Bay,Pelham_Gardens,Port_Morris,Riverdale,Schuylerville,Soundview,Spuyten_Duyvil,Throgs_Neck,Unionport,University_Heights,Van_Nest,Wakefield,West_Farms,Westchester_Square,Williamsbridge,Woodlawn"
   staten_island = "Annadale,Arden_Heights,Arlington,Arrochar,Bay_Terrace,Bloomfield,Bullshead,Castleton_Corners,Charleston,Chelsea,Clifton,Concord,Dongan_Hills,Elm_Park,Eltingville,Emerson_Hill,Graniteville,Grant_City,Grasmere,Great_Kills,Grymes_Hill,Heartland_Village,Howland_Hook,Huguenot,Lighthouse_Hill,Mariner,Midland_Beach,New_Brighton,New_Dorp,New_Dorp_Beach,New_Springville,Oakwood,Old_Town,Park_Hill,Pleasant_Plains,Port_Richmond,Princes_Bay,Randall_Manor,Richmond_Town,Richmond_Valley,Rosebank,Rossville,Shore_Acres,Silver_Lake,St._George,Stapleton,Sunnyside,Todt_Hill,Tompkinsville,Tottenville,West_Brighton,Westerleigh,Woodrow"

   
   # California
   san_francisco = "Bayview/Hunters_Point,Bernal_Heights,Castro,Chinatown,Civic_Center/Tenderloin,Cole_Valley,Crocker-Amazon,Diamond_Heights,Dogpatch,Embarcadero,Excelsior,Financial_District,Fisherman's_Wharf,Glen_Park,Haight-Ashbury,Hayes_Valley,Ingleside,Inner_Richmond,Inner_Sunset,Japantown,Lakeside,Laurel_Heights,Lower_Haight,Lower_Pac_Heights,Marina/Cow_Hollow,Miraloma,Mission,Mission_Terrace,Nob_Hill,Noe_Valley,North_Beach/Telegraph_Hill,Outer_Richmond,Outer_Sunset,Pacific_Heights,Parkside,Portola,Potrero_Hill,Russian_Hill,SOMA,Twin_Peaks,Union_Square,Visitacion_Valley,West_Portal,Western_Addition/NOPA"
   oakland = "Dimond_District,Downtown_Oakland,East_Oakland,Fruitvale,Glenview,Grand_Lake,Jack_London_Square,Lake_Merritt,Lakeshore,Laurel_District,Lower_Hills,Montclair_Village,North_Oakland,Oakland_Chinatown,Oakland_Hills,Old_Oakland,Piedmont,Piedmont_Ave,Rockridge,Temescal,Uptown,West_Oakland"
   berkeley = "Claremont,Downtown_Berkeley,East_Solano_Ave,Elmwood,Fourth_Street,Gourmet_Ghetto,North_Berkeley,North_Berkeley_Hills,South_Berkeley,Telegraph_Ave,UC_Campus_Area"
   ca_other = "San_Leandro::,Alameda::,San_Lorenzo::,Hayward::,Union_city::,Fremont::,Santa_Clara::,San_Jose::,Cupertino::,Campbell::,Sunnyvale::,Palo_Alto::,Los_Altos::,North_Fair_Oaks::,Menlo_Park::,Redwood_city::,San_Carlos::,Belmont::,San_Mateo::,San_Bruno::,Los_Gatos::,Milpitas::,Newark::,Castro_Valley::,Richmond::,East_Palo_Alto::,Saratoga::,Alviso::,Belmont::,Burlingame::,Campbell::,Cupertino::,East_Palo_Alto::,Foster_City::,Fremont::,La_Honda::,Los_Altos::,Menlo_Park::,Newark::,Palo_Alto::,Portola_Valley::,Redwood_Shores::,San_Carlos::,San_Jose::,San_Mateo::,Santa_Clara::,Saratoga::,Stanford::,Union_City::,Woodside::"
   
   # categories = "food,burgers,italian,newamerican,tradamerican,asianfusion,bars,breakfast_brunch,catering,chinese,coffee,hotdogs,foodstands,french,indpak,japanese,lounges,mediterranean,mexican,nightlife,pizza,restaurants,sushi,thai,vietnamese,bakeries,dimsum,desserts,delis,sandwiches,seafood,steak,wine_bars,afghani,ethnicmarkets,mideastern,african,latin,argentine,gluten_free,peruvian,spanish,tapas,tapasmallplates,vegan,hawaiian,bbq,chinese,korean,basque,belgian,brazilian,brasseries,british,buffets,burmese,cafes,cajun,cambodian,caribbean,cheesesteaks,chicken_wings,indonesian,creperies,cuban,diners,ethiopian,filipino,fishnchips,fondue,gastropubs,german,greek,halal,himalayan,hungarian,irish,kosher,raw_food,malaysian,modern_european,mongolian,moroccan,pakistani,persian,peruvian,polish,portuguese,russian,salad,scandinavian,singaporean,soulfood,soup,southern,taiwanese,tex-mex,turkish,ukrainian,vegetarian,donuts,dumplings,trucks,juice,bars,smoothies,ramen,chocolate,breweries,pubs,divebars,beer_and_wine,champagne_bars,icecream,bagels,tea,wineries"
   categories = "tradamerican,asianfusion,bars,breakfast_brunch,catering,chinese,coffee,hotdogs,foodstands,french,indpak,japanese,lounges,mediterranean,mexican,nightlife,pizza,restaurants,sushi,thai,vietnamese,bakeries,dimsum,desserts,delis,sandwiches,seafood,steak,wine_bars,afghani,ethnicmarkets,mideastern,african,latin,argentine,gluten_free,peruvian,spanish,tapas,tapasmallplates,vegan,hawaiian,bbq,chinese,korean,basque,belgian,brazilian,brasseries,british,buffets,burmese,cafes,cajun,cambodian,caribbean,cheesesteaks,chicken_wings,indonesian,creperies,cuban,diners,ethiopian,filipino,fishnchips,fondue,gastropubs,german,greek,halal,himalayan,hungarian,irish,kosher,raw_food,malaysian,modern_european,mongolian,moroccan,pakistani,persian,peruvian,polish,portuguese,russian,salad,scandinavian,singaporean,soulfood,soup,southern,taiwanese,tex-mex,turkish,ukrainian,vegetarian,donuts,dumplings,trucks,juice,bars,smoothies,ramen,chocolate,breweries,pubs,divebars,beer_and_wine,champagne_bars,icecream,bagels,tea,wineries"

    neighborhoods = {
      :NY => {
        :New_York => {
          # :Manhattan => manhattan.split(','),
          # :Brooklyn => brooklyn.split(','),
          # :Queens => queens.split(','),
          # :Bronx => bronx.split(','),
          # :Staten_Island => staten_island.split(',')
        }
      },
      :CA => {
        :San_Francisco => san_francisco.split(','),
        # :Oakland => oakland.split(','),
        # :Berkeley => berkeley.split(','),
        # :Other => ca_other.split(',')
      }
    }
    
    # if resume = ParserStat.where(:status => false).order("created_at").first
    #   loc = resume.find_loc.gsub(',','').spli('+').reverse
    #   
    # end
    
    urls = []
    neighborhoods.each do |state,v|
      v.each do |city, v| 
        
        if city == :Other
          v.each do |city|              
            
            find_loc = "#{city.to_s.gsub('_', '+').gsub('::', '')},+#{state.to_s}"
            filters_cities = "#{state}:#{city}" # state:{city_with_unerscores_and_two_dots_at_the_end::}                                  
            url_city = "http://www.yelp.com/search/snippet?attrs=&cflt=&find_desc=restaurants&find_loc=#{find_loc}&l=p:#{filters_cities}&rpp=40"
            urls.push(url_city)
            urls = urls | make_categories(categories,find_loc)
            
          end
        else
          find_loc = "#{city.to_s.gsub('_', '+')},+#{state.to_s}" # {city+with+pluses}+state
          
          v.each do |district, v| 
            # urls = urls | make_categories(categories,"#{district.to_s.gsub('_', '+')},+#{state.to_s}")           
            if v.class == Array
              v.each do |area|              
                filters_cities = "#{state}:#{city}:#{district}:#{area}" # state:{city_with_unerscores}:district:area   
                url_city = "http://www.yelp.com/search/snippet?attrs=&cflt=&find_desc=restaurants&find_loc=#{find_loc}&l=p:#{filters_cities}&rpp=40"
                urls.push(url_city)                
              end 
            else
              filters_cities = "#{state}:#{city}::#{district}" # state:{city_with_unerscores}::district
              url_city = "http://www.yelp.com/search/snippet?attrs=&cflt=&find_desc=restaurants&find_loc=#{find_loc}&l=p:#{filters_cities}&rpp=40"
              urls.push(url_city)
            end            
          end
          
        end
      end
    end
    
    urls.each do |url|
      go_sub(url+"&sortby=review_count")
      go_sub(url+"&sortby=rating")
      go_sub(url)
    end
    p "Done!"
  
end


def make_categories(categories,find_loc)
  urls = []
  categories.split(',').each do |c|
    url_category = "http://www.yelp.com/search/snippet?rpp=40&find_loc=#{find_loc}&cflt=#{c}&find_desc=restaurants"
    urls.push(url_category) 
  end
  urls
end

def recov_cat
  Restaurant.where(:source => 'fsq_upd_ylp').each do |r|
    r.restaurant_categories.split(',').each do |name|
      
      if name != "#{name.to_i}"
        if category = RestaurantCategory.find_by_name(name)
          categories.push(category.id)
        else
          categories.push(RestaurantCategory.create(:name => name).id)
        end
        r.restaurant_categories = categories.join(',')
        r.save
      end
      
    end
  end
end


def fill_4sq_with_yel
  Restaurant.where("source = 'foursquare' and city != 'Minsk' and city != 'Санкт-Петербург' and city != 'Калуга' and city != 'Домодедовский район' and city != 'город Калуга'").each do |r|
    
    location = CGI.escape("#{r.city} #{r.address}")
    name = CGI.escape(r.name)
    url = "http://www.yelp.com/search/snippet?find_desc=#{name}&find_loc=#{location}&mapsize=small&ns=1&rpp=40&sortby=best_match&start=0"
    
    if src = open(url.gsub("/search?", "/search/snippet?")) 
      json = JSON.parse(src.read)
      
      if ds = json['events']['search.map.overlays'].first

        doc = Nokogiri::HTML(open("http://www.yelp.com#{ds['url']}"))
        data = {}  
        cat = categories = []
  
        unless doc.css('span#cat_display a').blank? 
          doc.css('span#cat_display a').each do |c|
            cat.push(c.text.strip)
          end
        end

        if cat.nil?
          cat.split(',').each do |name|
            if category = RestaurantCategory.find_by_name(name)
              categories.push(category.id)
            else
              categories.push(RestaurantCategory.create(:name => name).id)
            end
          end
        end
        c1 = categories.any? ? categories.join(',') : ''
    
        data[:cc] = doc.css('dd.attr-BusinessAcceptsCreditCards')[0].text unless doc.css('dd.attr-BusinessAcceptsCreditCards').blank?
    
        if data[:cc] == 'Yes'
          data[:cc] = 1
        elsif data[:cc] == 'No'
          data[:cc] = 0
        end

        data[:terrace] = doc.css('dd.attr-OutdoorSeating')[0].text unless doc.css('dd.attr-OutdoorSeating').blank?
        if data[:terrace] == 'Yes'
          data[:terrace] = 1
        elsif data[:terrace] == 'No'
          data[:terrace] = 0
        end

        if data[:delivery] == 'Yes'
          data[:delivery] = 1
        elsif data[:delivery] == 'No'
          data[:delivery] = 0
        end
    
        if !doc.css('dd.attr-BusinessHours')[0].nil?
          hours = f_hours(doc.css('dd.attr-BusinessHours')[0].text)
          hours.each{ |k| data.merge!(k)}
        end
        data[:source] = 'fsq_upd_ylp'
        
        data[:ylp_rating] = "#{doc.css('img.rating.average')[0]["title"][0..2]}" unless doc.css('img.rating.average').blank? 
        data[:ylp_reviews_count] = "#{doc.css('span.review-count')[0].text.to_i}" unless doc.css('span.review-count').blank? 
    
        data[:restaurant_categories] = c1 if !c1.blank? 
        data[:city] = doc.css('span.locality')[0].text if !doc.css('span.locality').blank? && r.city.blank?
        data[:phone] = doc.css('span#bizPhone')[0].text if !doc.css('span#bizPhone')[0].nil? && r.phone.blank?
        data[:web] = doc.css('div#bizUrl a')[0].text unless doc.css('div#bizUrl a').blank? && r.web.blank?
        data[:transit] = doc.css('dd.attr-transit')[0].text.strip unless doc.css('dd.attr-transit').blank?
        data[:parking] = doc.css('dd.attr-BusinessParking')[0].text unless doc.css('dd.attr-BusinessParking').blank?

        data[:bill] = doc.css('span#price_tip')[0].text.count('$')  unless doc.css('span#price_tip').blank?
        data[:attire] = doc.css('dd.attr-RestaurantsAttire')[0].text unless doc.css('dd.attr-RestaurantsAttire').blank?
        data[:good_for_groups] = doc.css('dd.attr-RestaurantsGoodForGroups')[0].text unless doc.css('dd.attr-RestaurantsGoodForGroups').blank?
        data[:good_for_kids] = doc.css('dd.attr-GoodForKids')[0].text unless doc.css('dd.attr-GoodForKids').blank?
        data[:reservation] = doc.css('dd.attr-RestaurantsReservations')[0].text unless doc.css('dd.attr-RestaurantsReservations').blank?
        data[:delivery] = doc.css('dd.attr-RestaurantsDelivery')[0].text unless doc.css('dd.attr-RestaurantsDelivery').blank?
        data[:takeaway] = doc.css('dd.attr-RestaurantsTakeOut')[0].text unless doc.css('dd.attr-RestaurantsTakeOut').blank?
        data[:service] = doc.css('dd.attr-RestaurantsTableService')[0].text unless doc.css('dd.attr-RestaurantsTableService').blank?
    
        data[:wifi] = doc.css('dd.attr-WiFi')[0].text unless doc.css('dd.attr-WiFi').blank?
        data[:good_for_meal] = doc.css('dd.attr-GoodForMeal')[0].text unless doc.css('dd.attr-GoodForMeal').blank?
        data[:alcohol] = doc.css('dd.attr-Alcohol')[0].text unless doc.css('dd.attr-Alcohol').blank?
        data[:noise] = doc.css('dd.attr-NoiseLevel')[0].text unless doc.css('dd.attr-NoiseLevel').blank?
        data[:ambience] = doc.css('dd.attr-Ambience')[0].text unless doc.css('dd.attr-Ambience').blank?
        data[:tv] = doc.css('dd.attr-HasTV')[0].text unless doc.css('dd.attr-HasTV').blank?
        data[:caters] = doc.css('dd.attr-Caters')[0].text unless doc.css('dd.attr-Caters').blank?
        data[:disabled] = doc.css('dd.attr-WheelchairAccessible')[0].text unless doc.css('dd.attr-WheelchairAccessible').blank?
        p r.name
        r.update_attributes(data)
      end
    end
  end
  
end

def go_sub(url)
  p url
  
  # proxy = 'http://200.186.179.215:80'
  # proxy = 'http://183.82.97.186:3128'
  # username = 'user'
  # password = 'password'

  # if src = open(url.gsub("/search?", "/search/snippet?"))
  
  begin
    if src = open(url.gsub("/search?", "/search/snippet?"), :proxy => proxy) # :proxy_http_basic_authentication => [URI.parse(proxy), username, password]
      json = JSON.parse(src.read)
  
      json['events']['search.map.overlays'].each do |ds|
        if ds['respos'].to_i > 0
        
          if YlpRestaurant.select(:id).find_by_ylp_uri(ds['url'])
            p "Existed: #{ds['respos']}: #{ds['url']}"
          
          else
            # doc = Nokogiri::HTML(open("http://www.yelp.com#{ds['url']}"))
          
            doc = Nokogiri::HTML(open("http://www.yelp.com#{ds['url']}", :proxy => proxy))
            data = {}  
            category = []
          
            unless doc.css('span#cat_display a').blank? 
              doc.css('span#cat_display a').each do |c|
                category.push(c.text.strip)
              end
            end

            data[:name] = doc.css('h1.fn.org')[0].text unless doc.css('h1.fn.org').blank?
            data[:ylp_uri] = ds['url']
            data[:lat] = ds['lat']
            data[:lng] = ds['lng']       
            data[:rating] = doc.css('img.rating.average')[0]["title"][0..2] unless doc.css('img.rating.average').blank? 
      
            data[:review_count] = doc.css('span.review-count')[0].text.to_i unless doc.css('span.review-count').blank? 
            data[:category] = category.join(',') if category.count > 0 
            data[:city] = doc.css('span.locality')[0].text if !doc.css('span.locality').blank?
            data[:address] = "#{doc.css('span.street-address')[0].text}, #{doc.css('span.locality')[0].text}, #{doc.css('span.region')[0].text}" if !doc.css('span.street-address').blank? && !doc.css('span.locality').blank? && !doc.css('span.region').blank?
      
            data[:phone] = doc.css('span#bizPhone')[0].text unless doc.css('span#bizPhone').blank?
            data[:web] = doc.css('div#bizUrl a')[0].text unless doc.css('div#bizUrl a').blank?
      
            data[:transit] = doc.css('dd.attr-transit')[0].text.strip unless doc.css('dd.attr-transit').blank?
            data[:hours] = doc.css('dd.attr-BusinessHours')[0].text unless doc.css('dd.attr-BusinessHours').blank?
            data[:parking] = doc.css('dd.attr-BusinessParking')[0].text unless doc.css('dd.attr-BusinessParking').blank?
            data[:cc] = doc.css('dd.attr-BusinessAcceptsCreditCards')[0].text unless doc.css('dd.attr-BusinessAcceptsCreditCards').blank?

            data[:price] = doc.css('span#price_tip')[0].text.count('$')  unless doc.css('span#price_tip').blank?
            data[:attire] = doc.css('dd.attr-RestaurantsAttire')[0].text unless doc.css('dd.attr-RestaurantsAttire').blank?
            data[:groups] = doc.css('dd.attr-RestaurantsGoodForGroups')[0].text unless doc.css('dd.attr-RestaurantsGoodForGroups').blank?
            data[:kids] = doc.css('dd.attr-GoodForKids')[0].text unless doc.css('dd.attr-GoodForKids').blank?
            data[:reservation] = doc.css('dd.attr-RestaurantsReservations')[0].text unless doc.css('dd.attr-RestaurantsReservations').blank?
            data[:delivery] = doc.css('dd.attr-RestaurantsDelivery')[0].text unless doc.css('dd.attr-RestaurantsDelivery').blank?
            data[:takeout] = doc.css('dd.attr-RestaurantsTakeOut')[0].text unless doc.css('dd.attr-RestaurantsTakeOut').blank?
            data[:table_service] = doc.css('dd.attr-RestaurantsTableService')[0].text unless doc.css('dd.attr-RestaurantsTableService').blank?
            data[:outdoor_seating] = doc.css('dd.attr-OutdoorSeating')[0].text unless doc.css('dd.attr-OutdoorSeating').blank?

            data[:wifi] = doc.css('dd.attr-WiFi')[0].text unless doc.css('dd.attr-WiFi').blank?
            data[:meal] = doc.css('dd.attr-GoodForMeal')[0].text unless doc.css('dd.attr-GoodForMeal').blank?
            data[:alcohol] = doc.css('dd.attr-Alcohol')[0].text unless doc.css('dd.attr-Alcohol').blank?
            data[:noise] = doc.css('dd.attr-NoiseLevel')[0].text unless doc.css('dd.attr-NoiseLevel').blank?
            data[:ambience] = doc.css('dd.attr-Ambience')[0].text unless doc.css('dd.attr-Ambience').blank?
            data[:tv] = doc.css('dd.attr-HasTV')[0].text unless doc.css('dd.attr-HasTV').blank?
            data[:caters] = doc.css('dd.attr-Caters')[0].text unless doc.css('dd.attr-Caters').blank?
            data[:wheelchair_accessible] = doc.css('dd.attr-WheelchairAccessible')[0].text unless doc.css('dd.attr-WheelchairAccessible').blank?
        
            YlpRestaurant.create(data)
            p "Created: #{ds['respos']}: #{ds['url']}"
          end
        end
      end
      go_sub(json['seoPaginationUrls']['relNextUrl']) if json['seoPaginationUrls'] && !json['seoPaginationUrls']['relNextUrl'].blank?
    end
  rescue Exception => e
    if e.message.to_s != "^C"
      p e.message
      go_sub(url)
    end
  end
end

def f_hours(restaurant_hours)   
  week = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
  
  all_data = []  
  
  restaurant_hours.split("\n\t\t\t").each do |l|
    l.split(',').each do |lp|
      data = {}
      from = ''
      to = ''
      
      week.each {|wd| from = week.index(wd) if lp =~ /^ ?#{wd}/}
      week.each {|wd| to = week.index(wd) if lp =~ /-#{wd}/}
      to = from if to.blank?
    
      week[from..to].each do |wd|
        if m = l.match(/(\d{1,2}:?\d{0,2} ?(pm|am)) ?- ?(\d{1,2}:?\d{0,2} ?(pm|am))/)
        
          t_from = Time.parse(m[1]).strftime("%H:%M")
          t_to =Time.parse(m[3]).strftime("%H:%M")
        
          t_to.gsub!(/^\d{2}/, "#{t_to.to_i+24}") if t_from.to_i > t_to.to_i
          data[:"#{wd.downcase}"] = "#{t_from}-#{t_to}"    
          
        end
      end
      
      all_data << data  
    end
  end
  
  all_data
end
