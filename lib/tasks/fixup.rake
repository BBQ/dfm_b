# encoding: utf-8

def set_offset
  Timezone::Configure.begin do |c|
    c.username = 'innty'
    c.url = 'api.geonames.org'
  end
  begin
    Restaurant.where('time_zone_offset IS NULL AND lat IS NOT NULL AND lon IS NOT NULL').each do |r|
      p "#{r.id}: #{r.lat},#{r.lon}"
      if timezone = Timezone::Zone.new(:latlon => [r.lat,r.lon])
        r.time_zone_offset = ActiveSupport::TimeZone.create(timezone.zone).formatted_offset
        r.save
        p "#{r.name}: #{r.time_zone_offset}"
      else
        p "#{r.name}: NO ZONE!"
      end
    end
  rescue
    set_offset
  end
    
end

namespace :fixup do
  
  desc "Set TimeZone offset for restaurants"
  task :set_offset => :environment do
    set_offset
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
      UserPreference.create({:user_id => user.id})
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
    Dish.where('fsq_checkins_count = 0').each do |d|
      p d.name
      c = d.network.restaurants.order('fsq_checkins_count DESC').limit(1)
      if r = c[0]
        d.fsq_checkins_count = r.fsq_checkins_count ||= 0
        d.save
      end
    end
    
    Network.all.each do |n|
      c = n.restaurants.order('fsq_checkins_count DESC').limit(1)
      if r = c[0]
        n.fsq_checkins_count = r.fsq_checkins_count ||= 0
        n.save
      end
    end
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
  
  
end