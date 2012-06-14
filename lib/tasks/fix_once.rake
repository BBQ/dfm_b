# encoding: utf-8

def set_offset(lat,lon)
    
  server = 'earthtools.org'
  port = '80'
  url = "/timezone/#{lat}/#{lon}"
  
  http = Net::HTTP.new(server, port)
  req = Net::HTTP::Get.new(url)
  
  response = http.request(req)
  data = response.body
  
  if match =/<offset>(.)(.)<\/offset>/.match(data)
    offset = "#{match[1]}0#{match[2]}:00".strip
  end

  offset
end

namespace :fixup do
  
  task :mg_cat => :environment do
    file_name = "rc.xls"

    directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/'
    file = directory + file_name
    
    parser = Excel.new(file, false, :ignore)  
    dish_sheet = parser.sheets[0]
    
    1.upto(parser.last_row(dish_sheet)) do |line|
      
      c2 = parser.cell(line,'A', dish_sheet).to_i.to_s
      c1 = parser.cell(line,'F', dish_sheet).to_i.to_s
      e = parser.cell(line,'E', dish_sheet).to_i
      
      # Merge
      # if c1 != '0'
      #   rsts = Restaurant.where("restaurant_categories REGEXP '(^#{c2},|,#{c2},|,#{c2}$|^#{c2}$)'")
      #   rstsc = rsts.count
      #   rsts.each do |r|
      #     b = r.restaurant_categories.match /(^#{c2},|,#{c2},|,#{c2}$|^#{c2}$)/
      #     unless b.nil?
      #       c = b[0].gsub(c2,c1)
      #       r.restaurant_categories = r.restaurant_categories.gsub(b[0], c)
      #       r.save
      #       if rc = RestaurantCategory.find_by_id(c2)
      #         rc.destroy
      #       end
      #     end
      #     
      #   end
      #   p "#{rstsc} replaced #{c2} with #{c1}"
      # end
      
      # Clean
      if e == 0
        rsts = Restaurant.where("restaurant_categories = '#{c2}' AND source = 'ylp'")
        rsts.each do |r|
          p "#{r.id} #{r.name} #{r.address}"
          r.update_attributes(:active => 0)
        end
      end
      
    end
  end
  
  task :ylp_score => :environment do
    Restaurant.select([:id, :name, :lat, :lon, :ylp_rating, :ylp_reviews_count]).where("source = 'ylp'").each do |r|
      
      if yr = YlpRestaurant.select([:rating, :review_count, :rating]).find_by_name_and_lat_and_lng(r.name, r.lat, r.lon)
        if yr.rating
          
          r.ylp_rating = yr.rating
          r.ylp_reviews_count = yr.review_count
          r.save
          p "#{r.id}:#{r.name} #{r.ylp_rating}, #{r.ylp_reviews_count}"
          
        end
      end
      
    end
  end
  
  task :work_hour_c => :environment do
    Restaurant.select([:id, :name, :lat, :lon]).where("source != 'ylp'").each do |r|
      
      if yr = YlpRestaurant.select(:hours).find_by_name_and_lat_and_lng(r.name, r.lat, r.lon)
        if yr.hours
          
          f_hours(yr.hours).each do |h|
            h[:restaurant_id] = r.id
            h[:time_zone_offset] = set_offset(r.lat,r.lon)
            puts h
            WorkHour.create(h)
          end
          
        end
      end
      
    end
  end
  
  desc "Set TimeZone offset for work hours"
  task :wh_set_offset => :environment do
    WorkHour.where('time_zone_offset IS NULL AND id > 5200 AND id <= 10000').group(:restaurant_id).each do |wh|
      r = Restaurant.where('lat IS NOT NULL AND lon IS NOT NULL AND id = ?', wh.restaurant_id)
      if rest = r.first
        if tzo = set_offset(rest.lat, rest.lon)
          WorkHour.where(:restaurant_id => wh.restaurant_id).update_all({:time_zone_offset => tzo})
          p "#{rest.name}: #{tzo}"
        else
          p "#{rest.id}:#{rest.name}: NO ZONE!"
        end
      end
    end
  end
  
  desc "Set TimeZone offset for restaurants"
  task :set_offset => :environment do
    Restaurant.where('time_zone_offset IS NULL AND lat IS NOT NULL AND lon IS NOT NULL').each do |r|
      p "#{r.id}: #{r.lat},#{r.lon}"
      if tzo = set_offset(r.lat,r.lon)
        p "#{r.name}: #{r.time_zone_offset}"
        r.time_zone_offset = tzo
        r.save
      else
        p "#{r.name}: NO ZONE!"
      end
    end
  end

  desc "Copy Dishes to DishDelivery"
  task :cp_dish_dlv => :environment do
    Restaurant.where(:delivery => 1).group(:network_id).each do |r|
      r.network.dishes.each do |d|
        DishDelivery.create(d)
      end
    end
  end  
  
  
  desc "Fill Dilevery with :bill"
  task :delivery_bill => :environment do
    Delivery.all.each do |d|
      if r = Restaurant.find_by_name(d.name)
        p "#{r.name}: #{r.bill}"
        d.update_attributes(:bill => r.bill) if r.bill
      end
    end
  end
  
  desc "Find similar categories in RestaurantCategory"
  task :rc_sim => :environment do
    p "Getting Restaurants ... "
    restaurants = Restaurant.select([:id, :restaurant_categories]).all
    p "got it! "
    p "Begin with Categories ... "
    RestaurantCategory.where("(LENGTH(name) - LENGTH(REPLACE(name, ' ', ''))+1) = 1").each do |c|
      RestaurantCategory.where("name REGEXP '^#{c.name}' AND name != ?", c.name).each do |rc|
        p "Do you want to merge #{c.id}:#{c.name} with #{rc.id}:#{rc.name} y/n:"
        if STDIN.gets.count('y') != 0
          p "Merging ..."
          restaurants.each do |r|
            if r.restaurant_categories
              rc_array = r.restaurant_categories.split(',')
              
              if rc_array.index(rc.id.to_s)
                rc_array.delete_if {|i| i == rc.id.to_s}
                rc_array.push(c.id)
                r.restaurant_categories = rc_array.join(',')
                r.save
              end
              
            end
          end
          rc.delete
          p "this done!"
        else
          p "Skiped"
        end
      end  
         
    end
  end
  
  desc "Delete dublicates in restaurants"
  task :del_dbl_res => :environment do
    exclude = Review.group('restaurant_id').all.collect {|rw| rw.restaurant_id}.compact.reject{|id| id.to_s.blank?}.join(',')
    
    Restaurant.group('fsq_id').having('count(*) > 1').where("fsq_id IS NOT NULL AND source = 'ylp'").order(:id).each do |r|
      p "#{r.id}:#{r.name}"
      Restaurant.delete_all("fsq_id = '#{r.fsq_id}' AND id != '#{r.id}' AND id NOT IN (#{exclude})")
    end
    
    if networks_with_rest = Network.select('networks.id').joins(:restaurants).group('networks.id').collect {|n| n.id}.compact.reject{|id| id.to_s.blank?}.join(',')
      Dish.delete_all("network_id not IN (#{networks_with_rest})")
      Network.delete_all("id not IN (#{networks_with_rest})")
    end
    
    if all_restaurants = Restaurant.select(:id).all.collect {|n| n.id}.compact.reject{|id| id.to_s.blank?}.join(',')
      RestaurantType.delete_all("restaurant_id not IN (#{all_restaurants})")
      RestaurantImage.destroy_all("restaurant_id not IN (#{all_restaurants})")
      RestaurantCuisine.delete_all("restaurant_id not IN (#{all_restaurants})")
      DishCategoryOrder.delete_all("restaurant_id not IN (#{all_restaurants})")
      RestaurantTag.delete_all("restaurant_id not IN (#{all_restaurants})")
    end
    
  end
  
  task :set_rev_loc => :environment do
    Review.all.each do |r|
      if r.restaurant
      r.lat = r.restaurant.lat if r.restaurant.lat
      r.lng = r.restaurant.lon if r.restaurant.lon
      r.save
      end
    end
    p 'Done'
  end
  
  #TODO: Start rake fix:add_r_img, tags:match_dishes, tags:match_rest on Test Server foursquare check_ins
  desc "Add Images to Restaurant"
  task :add_r_img => :environment do  
    dir = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/r_img'
    
    Dir.new(dir).entries.each do |f|
      if rest = Restaurant.find_by_id(f.to_i)
        rest.network.restaurants.each do |r|
          r.restaurant_images.create(:photo => File.open(dir + '/' + f) )
          p "#{r.id} #{f}"
        end
        
      end
    end
  end  
  
  desc "Make user_preferences records for Users"
  task :make_u_pref => :environment do  
    User.all.each do |user|
      unless UserPreference.find_by_user_id user.id
        UserPreference.create({:user_id => user.id})
        p "Prefs added for user #{user.id}:#{user.name}"
      end
    end
  end

  desc "Copy dishes to dish_delivery"
  task :cp_dishes_delivery => :environment do
    directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/public'
    
    Delivery.all.each do |r|
      
      if n = Restaurant.find_by_name(r.name).network
        p r.name
        n.dishes.each do |d|
          data = {
            :name => d.name,
            :photo => d.photo.url == '/images/noimage.jpg' ? '' : File.open(directory + d.photo.url),
            :price =>d.price, 
            :currency => d.currency, 
            :rating => 0, 
            :votes => 0, 
            :description => d.description, 
            :delivery_id => r.id, 
            :dish_category_id => d.dish_category_id, 
            :dish_type_id => d.dish_type_id, 
            :dish_subtype_id => d.dish_subtype_id, 
            :top_user_id => 0, 
            :dish_extratype_id => d.dish_extratype_id, 
            :created_by_user => 0, 
            :count_comments => 0, 
            :count_likes => 0, 
            :no_rate_order => d.no_rate_order
          }
          DishDelivery.create(data) unless DishDelivery.find_by_name_and_delivery_id(data[:name],data[:delivery_id])
        end
      else
        p "#{r.name} not found!"
      end
    end
  end  
  
  desc "Fill restaurants with cities"
  task :city => :environment do
    Restaurant.where('city IS NULL').each do |r|
      if result = Geocoder.search("#{r.lat},#{r.lon}")[0]
        p "#{r.id}. #{r.name}"
        if city = result.address_components[3]
          if city['long_name'] == 'Moscow'
            r.city = city['long_name']
          else
            r.city = result.address_components[2]['long_name']
          end
        else
          r.city = result.address_components[1]['long_name']
        end
        r.save
      end
    end
  end
  
  desc "Update no_rate_order for Dishes"
  task :dish_norate => :environment do
    i = 1
    Dish.where('rating = 0').order("fsq_checkins_count DESC, photo DESC, description DESC, updated_at DESC, price DESC").each do |d|
      d.no_rate_order = i
      p d.id
      d.save
      i += 1
    end
  end
  
  desc "Update Ratings for Networks"
  task :n_rating => :environment do
    Network.where('rating > 0 OR votes > 0').each do |n|
      n.rating = 0
      n.votes = 0
      n.save
    end
      Review.select(:network_id).group(:network_id).each do |rw|
        if data = Network.find_by_id(rw.network_id)
          p "#{data.id} #{data.name}"
          summ = 0
          data.reviews.each {|rr| summ += rr.rating}

          data.votes = data.reviews.count
          data.rating = summ/data.votes

          data.save
        end
      end
  end
  
  desc "Update Ratings for Restaurants"
  task :r_rating => :environment do
      Restaurant.where('rating > 0 OR votes > 0').each do |r|
        r.rating = 0
        r.votes = 0
        r.save
      end
      Review.select(:restaurant_id).group(:restaurant_id).each do |rw|
        if rest = Restaurant.find_by_id(rw.restaurant_id)
          p "#{rest.id} #{rest.name}"
          summ = 0
          rest.reviews.each {|rr| summ += rr.rating}

          rest.votes = rest.reviews.count
          rest.rating = summ/rest.votes

          rest.save
        end
      end
  end
  
  desc "Update Ratings for Dishes"
  task :d_rating => :environment do
    Dish.where('rating > 0 OR votes > 0').each do |d|
      d.rating = 0
      d.votes = 0
      d.save
    end
      Review.select(:dish_id).group(:dish_id).each do |rw|
        if dish = Dish.find_by_id(rw.dish_id)
          p "#{dish.id} #{dish.name}"
          summ = 0
          dish.reviews.each {|dr| summ += dr.rating}

          dish.votes = dish.reviews.count
          dish.rating = summ/dish.votes

          dish.save
        end
      end
  end
  
  desc "Update Foursquare User Checkins for Dishes by setting max(Foursquare User Checkins) from network resataurant"
  task :dish_fsq => :environment do
    Dish.select([:id, :name, :network_id, :fsq_checkins_count]).where('fsq_checkins_count = 0').order('id DESC').each do |d|
      p d.name
      c = d.network.restaurants.order('fsq_checkins_count DESC').limit(1)
      if r = c[0]
        d.fsq_checkins_count = r.fsq_checkins_count ||= 0
        d.save
      end
    end
    
    # Network.all.each do |n|
    #   c = n.restaurants.order('fsq_checkins_count DESC').limit(1)
    #   if r = c[0]
    #     n.fsq_checkins_count = r.fsq_checkins_count ||= 0
    #     n.save
    #   end
    # end
  end

  desc "Update Restaurants set restaurants_count"
  task :rest_count => :environment do
    Restaurant.all.each do |r|
      r.count_dishes = r.network.dishes.count ||= 0
      r.save
    end
  end  
  

  desc "Update Dishes with information from networks"
  task :upd_dishes => :environment do
    Network.where('`fsq_users_count` IS NOT NULL OR `votes` > 0 OR `rating` > 0').each do |n|
      n.dishes.each do |d|
        d.network_fsq_users_count = n.fsq_users_count
        d.network_votes = n.votes
        d.network_rating = n.rating
        d.save
        p d.name
      end
    end
  end
  
  desc "Update Foursquare User Checkins for Networks by setting max(Foursquare User Checkins) from network resataurant"
  task :net_fsq => :environment do
    Network.all.each do |n|
      c = n.restaurants.order('fsq_checkins_count DESC').limit(1)
      if r = c[0]
        n.fsq_checkins_count = r.fsq_checkins_count ||= 0
        n.save
      end
    end
  end
  
  task :set_zero => :environment do
    Restaurant.all.each do |r|
      # fix wifi
      if r.wifi.to_i == '1' || r.wifi == 'true' || r.wifi == 'да'
        r.wifi = 1
      else
        r.wifi = 0
      end 
      r.save
    end
    puts 'done!'
  end
  
  desc "Recheck review likes"
  task :likes => :environment do
    Review.update_all({:count_likes => 0})
    Review.all.each do |r|
      p r
      r.count_likes = r.likes.count
      r.save
    end
  end
  
  task :phone => :environment do
    
    Restaurant.all.each do |r|
      unless r.phone.nil?
        
        p_arr = []    
        r.phone.split(/[,;]/).each do  |p|
        
          phone = p.gsub('.0','')
          phone = phone.gsub(/\D/,'').to_s
          
          if phone && phone.length <= 11
            
            dp = 0
            if phone.length == 11
              phone = "+7(#{phone[1,3]})-#{phone[4,3]}-#{phone[7,2]}-#{phone[9,2]}" if phone[0] == '7'
              phone = "+7(#{phone[1,3]})-#{phone[4,3]}-#{phone[7,2]}-#{phone[9,2]}" if phone[0] == '8'
              phone = "+7(495)-#{phone[0,3]}-#{phone[3,2]}-#{phone[5,2]} доб.(#{phone[7,4]})" if !phone['2218381'].nil? # coffeehouse.ru
              dp = 1
            elsif phone.length == 10
              phone = "+7(#{phone[0,3]})-#{phone[3,3]}-#{phone[6,2]}-#{phone[8,2]}"
              dp = 1
            elsif phone.length == 7
              phone = "+7(495)-#{phone[0,3]}-#{phone[3,2]}-#{phone[5,2]}"
              dp = 1
            elsif !p['--- {}'].nil?
              phone = nil
              dp = 1
            end
            
            if dp == 1 
              p_arr.push(phone)
            elsif count = p_arr.count
              p_arr[count] = "#{p_arr.last} доб.(#{phone})"
            end
            
          else
            p "fix me :#{r.id} - #{p}"
          end
        end
        r.phone = p_arr.join('; ')
        r.save
        p "#{r.id} #{r.phone}"
      end
    end
  end
  
  task :wh => :environment do
    Restaurant.select([:time, :id, :time_zone_offset]).where("time IS NOT NULL").each do |r|
      work_hours(r.time).each do |wh|
        unless wh.blank?
          wh[:restaurant_id] = r.id
          wh[:time_zone_offset] = r.time_zone_offset
          p wh
          WorkHour.create(wh)
        end
      end
    end
  end
  
  task :wh_ru => :environment do
    Restaurant.select([:time, :id, :time_zone_offset]).where("time IS NOT NULL").each do |r|
      work_hours_ru(r)
    end
  end
  
end

def work_hours_ru(restaurant)
  days_ru = ['пн','вт','ср','чт','пт','сб','вс']
  days_en = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
  
  trace = []
  
  start = finish = []
  close_time = close_time = ''
  restaurant_hours = restaurant.time
  
  data = restaurant_hours.scan(/(пн|вт|ср|чт|пт|сб|вс|,|-|\d{1,2}[.:]\d{1,2}|последнего|круглосуточно)/i)
  data.each do |d|
    
    if pos = days_ru.index(d.downcase)
      if !from.any?
        start = push(days_en[pos])
      else
        if days_en[pos-1] = '-'
          finish = push(days_en[pos])            
        elsif days_en[pos-1] = ','
          start = push(days_en[pos])
          finish = push('') if (start.count - finis.count) == 2
        end
      end
      
    else
      if d =~ /\d{1,2}[.:]\d{1,2}/
        if start_time.nil?
          start_time = d
        else
          close_time = d
        end
      elsif d == 'последнего'
        close_time = '24:00'
      elsif d == 'круглосуточно'
        start_time = '00:00'
        close_time = '24:00'
      end  
       
    end
    
    if start_time && close_time
      start.each do |s|
        f = finish[start.index(s)]
        if !f.blank?
          data = {}
          days_en[s..f].each do |wd|
            data[wd.to_sym] = "#{start_time}-#{close_time}"
            data[:restaurant_id] = restaurant.id
            data[:time_zone_offset] = restaurant.time_zone_offset
            p data
            trace << data
            # WorkHour.create(data)
          end
        end
      end
      if !start.any?
        data = {}
        days_en[0..6].each do |wd|
          data[wd.to_sym] = "#{start_time}-#{close_time}"
          data[:restaurant_id] = restaurant.id
          data[:time_zone_offset] = restaurant.time_zone_offset
          p data
          trace << data
          # WorkHour.create(data)
        end
      end
    end
    trace
  end
  
  # if days_ru.index(data[0])
  #   if data[0] == '-'
  #     
  #   elsif data[0] == ','
  #     
  #   elsif data[0] =~ /\d{1,2}[.:]\d{1,2}/
  #     
  #   end
  # elsif data[0] =~ /\d{1,2}[.:]\d{1,2}/
  #   
  # end
  
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