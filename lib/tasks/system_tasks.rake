# encoding: utf-8
namespace :system do
  
  desc "Get information for restaurant from Yelp"
  task :get_yelp_info => :environment do
    get_yelp_info(ENV["RESTAURANT_ID"])
  end
  
  desc "Update Foursquare Checkins and Restaurant Menu"
  task :update_4sq_restaurants_info => :environment do
    update_4sq_restaurants_info
  end
  
  
end

def update_4sq_restaurants_info
  begin
    client = Foursquare2::Client.new(:client_id => $client_id, :client_secret => $client_secret)  
    restaurants = Restaurant.select([:id, :fsq_checkins_count, :fsq_tip_count, :fsq_users_count, :fsq_id, :updated_at]).where('fsq_id IS NOT NULL AND fsq_id != 0 AND updated_at < ?', (Time.now-2*24*60*60).strftime("%Y-%m-%d %H:%M:%S")).order(:id)
    
    restaurants.each do |r|
      $r = r
      if fsq_hash = client.venue($r.fsq_id)    
        p "#{$r.id}: #{$r.fsq_id}: #{$r.updated_at}"
        $r.fsq_checkins_count = fsq_hash[:stats][:checkinsCount]
        $r.fsq_tip_count = fsq_hash[:stats][:tipCount]
        $r.fsq_users_count = fsq_hash[:stats][:usersCount]
        $r.updated_at = Time.now
        $r.save
      end
    end     
    
  rescue Exception => e
    msg = e.message
    if msg.count('has been deleted')
      $r.fsq_id = msg.match(/Venue (.*) has/)[1]
      $r.save
    end
    p msg
    update_4sq_restaurants_info
  end
end

def get_yelp_info(restaurant_id)
  if r = Restaurants.find_by_id(restaurant_id)
  
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
        
        time = doc.css('dd.attr-BusinessHours')[0].text
        work_hours(time).each do |wh|
          wh[:restaurant_id] = r.id
          WorkHour.create(wh)
        end
        
      end
    end
    
  end
end

def work_hours(restaurant_hours)   
  
  all_data = []
  week = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
  
  if restaurant_hours.scan("\n\t\t\t")
    sp = "\n\t\t\t"
  elsif restaurant_hours.scan("\r\n")
    sp = "\r\n"
  end  
  
  restaurant_hours.split(sp).each do |l|
    l.split(',').each do |lp|
      data = {}
      from = 0
      to = 0
      
      week.each {|wd| from = week.index(wd) if lp =~ /^ ?#{wd}/}
      week.each {|wd| to = week.index(wd) if lp =~ /-#{wd}/}
      to = from if to.blank?

      if from != 0 && to != 0
        week[from..to].each do |wd|
          if m = l.match(/(\d{1,2}:?\d{0,2} ?(pm|am)) ?- ?(\d{1,2}:?\d{0,2} ?(pm|am))/)
        
            t_from = Time.parse(m[1]).strftime("%H:%M")
            t_to =Time.parse(m[3]).strftime("%H:%M")
        
            t_to.gsub!(/^\d{2}/, "#{t_to.to_i+24}") if t_from.to_i > t_to.to_i
            data[:"#{wd.downcase}"] = "#{t_from}-#{t_to}"    

          end
        end
      end

      all_data << data
    end
  end
  
  all_data
end