# encoding: utf-8
namespace :ylp do
  
  require 'oauth'
  require 'json'
  require 'net/http'
  require 'open-uri'
  require 'nokogiri'
  
  task :get_fsq  => :environment do
    YlpRestaurant.where('has_menu IS NULL').order(:id).each do |r|
      
      client = Foursquare2::Client.new(:client_id => $client_id, :client_secret => $client_secret)
      fsq_hash = client.search_venues(:ll => "#{r.lat},#{r.lng}", :query => r.name) if r.lat && r.lng && r.name
      
      if fsq_hash && fsq_hash.groups[0].items.count > 0

        category = []
        fsq_hash.categories.each do |v|
          category.push(v.name)
        end

        r.fsq_id = fsq_hash.groups[0].items.first.id        
        r.fsq_name = fsq_hash.groups[0].items.first.name
        r.fsq_address = fsq_hash.groups[0].items.first.location.address
        r.fsq_lat = fsq_hash.groups[0].items.first.location.lat
        r.fsq_lng = fsq_hash.groups[0].items.first.location.lng
        r.fsq_checkins_count = fsq_hash.groups[0].items.first.stats.checkinsCount
        r.fsq_users_count = fsq_hash.groups[0].items.first.stats.usersCount
        r.fsq_tip_count = fsq_hash.groups[0].items.first.stats.tipCount
        r.restaurant_categories = category.count > 0 ? category.join(',') : 0
        r.save
        p "#{r.id}:#{r.fsq_id} #{r.name} #{r.address}"
        
        client.venue_menu(r.fsq_id).each do |m|           
           m.entries.fourth.second.items.each do |i|
             i.entries.third.second.items.each do |d|  

               if d.prices 
                 price = /(.)(\d+\.\d+)/.match(d.prices.first)[2]
                 currency = /(.)(\d+\.\d+)/.match(d.prices.first)[1]
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
         p "   --- menu found! #{r.id}"
        end
         
      end
    end
  end
  
  task :parse => :environment do
    
    manhattan = "Alphabet_City,Battery_Park,Chelsea,Chinatown,Civic_Center,East_Harlem,East_Village,Financial_District,Flatiron,Gramercy,Greenwich_Village,Harlem,Hell's_Kitchen,Inwood,Kips_Bay,Koreatown,Little_Italy,Lower_East_Side,Manhattan_Valley,Marble_Hill,Meatpacking_District,Midtown_East,Midtown_West,Morningside_Heights,Murray_Hill,NoHo,Nolita,Roosevelt_Island,SoHo,South_Street_Seaport,South_Village,Stuyvesant_Town,Theater_District,TriBeCa,Two_Bridges,Union_Square,Upper_East_Side,Upper_West_Side,Washington_Heights,West_Village,Yorkville"
    brooklyn = "Bath_Beach,Bay_Ridge,Bedford_Stuyvesant,Bensonhurst,Boerum_Hill,Borough_Park,Brighton_Beach,Brooklyn_Heights,Brownsville,Bushwick,Canarsie,Carroll_Gardens,City_Line,Clinton_Hill,Cobble_Hill,Columbia_Street_Waterfront_District,Coney_Island,Crown_Heights,Cypress_Hills,DUMBO,Ditmas_Park,Downtown_Brooklyn,Dyker_Heights,East_Flatbush,East_New_York,East_Williamsburg,Flatbush,Flatlands,Fort_Greene,Fort_Hamilton,Georgetown,Gerritson_Beach,Gowanus,Gravesend,Greenpoint,Highland_Park,Kensington,Manhattan_Beach,Marine_Park,Midwood,Mill_Basin,Mill_Island,New_Lots,Ocean_Hill,Ocean_Parkway,Paedergat_Basin,Park_Slope,Prospect_Heights,Prospect_Lefferts_Gardens,Prospect_Park_South,Red_Hook,Remsen_Village,Sea_Gate,Sheepshead_Bay,South_Williamsburg,Spring_Creek,Starret_City,Sunset_Park,Vinegar_Hill,Weeksville,Williamsburg_-_North_Side,Williamsburg_-_South_Side,Windsor_Terrace,Wingate"
    queens = "Arverne,Astoria,Astoria_Heights,Auburndale,Bay_Terrace,Bayside,Beechurst,Bellaire,Belle_Harbor,Bellerose,Breezy_Point,Briarwood,Cambria_Heights,College_Point,Douglaston,Downtown_Flushing,East_Elmhurst,Edgemere,Elmhurst,Far_Rockaway,Floral_Park,Flushing,Flushing_Meadows,Forest_Hills,Fresh_Meadows,Glen_Oaks,Glendale,Hillcrest,Hollis,Holliswood,Howard_Beach,Hunters_Point,JFK_Airport,Jackson_Heights,Jamaica,Jamaica_Estates,Jamaica_Hills,Kew_Gardens,Kew_Gardens_Hills,LaGuardia_Airport,Laurelton,LeFrak_City,Lindenwood,Little_Neck,Long_Island_City,Malba,Maspeth,Middle_Village,Murray_Hill,North_Corona,Oakland_Gardens,Ozone_Park,Pomonok,Queens_Village,Queensborough_Hill,Rego_Park,Richmond_Hill,Ridgewood,Rochdale,Rockaway_Park,Rosedale,Seaside,Somerville,Springfield_Gardens,Steinway,Sunnyside,Utopia,Whitestone,Woodhaven,Woodside"
    bronx = "Baychester,Bedford_Park,Belmont,Castle_Hill,City_Island,Claremont_Village,Clason_Point,Co-op_City,Concourse,Concourse_Village,Country_Club,East_Tremont,Eastchester,Edenwald,Edgewater_Park,Fieldston,Fordham,High_Bridge,Hunts_Point,Kingsbridge,Longwood,Melrose,Morris_Heights,Morris_Park,Morrisania,Mott_Haven,Mount_Eden,Mount_Hope,North_Riverdale,Norwood,Olinville,Parkchester,Pelham_Bay,Pelham_Gardens,Port_Morris,Riverdale,Schuylerville,Soundview,Spuyten_Duyvil,Throgs_Neck,Unionport,University_Heights,Van_Nest,Wakefield,West_Farms,Westchester_Square,Williamsbridge,Woodlawn"
    staten_island = "Annadale,Arden_Heights,Arlington,Arrochar,Bay_Terrace,Bloomfield,Bullshead,Castleton_Corners,Charleston,Chelsea,Clifton,Concord,Dongan_Hills,Elm_Park,Eltingville,Emerson_Hill,Graniteville,Grant_City,Grasmere,Great_Kills,Grymes_Hill,Heartland_Village,Howland_Hook,Huguenot,Lighthouse_Hill,Mariner,Midland_Beach,New_Brighton,New_Dorp,New_Dorp_Beach,New_Springville,Oakwood,Old_Town,Park_Hill,Pleasant_Plains,Port_Richmond,Princes_Bay,Randall_Manor,Richmond_Town,Richmond_Valley,Rosebank,Rossville,Shore_Acres,Silver_Lake,St._George,Stapleton,Sunnyside,Todt_Hill,Tompkinsville,Tottenville,West_Brighton,Westerleigh,Woodrow"
    other = "Bayonne::,Belleville::,Bergenfield::,Bloomfield::,Bogota::,Carlstadt::,Cliffside_Park::,Clifton::,Cresskill::,Dumont::,East_Newark::,East_Rutherford::,Edgewater::,Elizabeth::,Elmwood_Park::,Englewood::,Englewood_Cliffs::,Fair_Lawn::,Fairview::,Fort_Lee::,Garfield::,Guttenberg::,Hackensack::,Harrison::,Hasbrouck_Heights::,Hawthorne::,Hoboken::,Jersey_City::,Kearny::,Leonia::,Little_Ferry::,Lodi::,Lyndhurst::,Maywood::,Moonachie::,New_Milford::,Newark::,North_Arlington::,North_Bergen::,Nutley::,Palisades_Park::,Paramus::,Passaic::,Paterson::,Ridgefield::,Ridgefield_Park::,River_Edge::,Rochelle_Park::,Rutherford::,Saddle_Brook::,Secaucus::,South_Hackensack::,Teaneck::,Tenafly::,Union_City::,Wallington::,Weehawken::,West_New_York::,Wood-Ridge::,Wood_Ridge::%5D,NY:%5BBronxville::,Corona::,Farmingville::,Larchmont::,Mount_Vernon::,Mt_Vernon::,New_Rochelle::,New_York_City::,Pelham::,Ronkonkoma::,Saint_Albans::,South_Ozone_Park::,South_Richmond_Hill::,Yonkers::"
    
    neighborhoods = {
      # :Manhattan => manhattan.split(','),
      # :Brooklyn => brooklyn.split(','),
      # :Queens => queens.split(','),
      # :Bronx => bronx.split(','),
      # :Staten_Island => staten_island.split(',')
    }
    
    headers = {
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Charset" => "windows-1251,utf-8;q=0.7,*;q=0.3",
      "Accept-Language" => "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4",
      "Cache-Control" => "max-age=0",
      "Connection" => "keep-alive",
      "Cookie" => open("http://www.yelp.com/search?rpp=40&find_desc=restaurants&ns=1&l=p:NY:New_York:Manhattan:Alphabet_City&find_loc=Alphabet_City,+New+York%2C+NY").meta['set-cookie'],
      "Host" => "www.yelp.com",
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.100 Safari/534.30"
    }
    url = "http://www.yelp.com/search/snippet?rpp=40&find_desc=restaurants&ns=1&l=p:NY:New_York:"  
      
    neighborhoods.each do |k,v|
      v.each do |n|          
        f = go_sub("#{url}#{k}:#{n}&find_loc=#{n},+New+York%2C+NY", headers)
        headers['Cookie'] = f.meta['set-cookie']
      end
    end
    
  end
end

def go_sub(url, headers)
  if src = open(url.gsub("/search?", "/search/snippet?"), headers)
    json = JSON.parse(src.read)
  
    json['events']['search.map.overlays'].each do |ds|
      if ds['respos'].to_i > 0
        
        if YlpRestaurant.find_by_ylp_uri(ds['url'])
          p "Existed: #{ds['respos']}: #{ds['url']}"
          
        else
          doc = Nokogiri::HTML(open("http://www.yelp.com#{ds['url']}"))
          data = {}  

          data[:name] = doc.css('h1.fn.org')[0].text unless doc.css('h1.fn.org').blank?
          data[:ylp_uri] = ds['url']
          data[:lat] = ds['lat']
          data[:lng] = ds['lng']       
          data[:rating] = doc.css('img.rating.average')[0]["title"][0..2] unless doc.css('img.rating.average').blank? 
      
          data[:review_count] = doc.css('span.review-count')[0].text.to_i unless doc.css('span.review-count').blank? 
          data[:category] = doc.css('span#cat_display a')[0].text.strip unless doc.css('span#cat_display a').blank? 
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
    go_sub(json['seoPaginationUrls']['relNextUrl'], headers) unless json['seoPaginationUrls']['relNextUrl'].blank?
  end
  src
end