# encoding: utf-8

# NY 
# 1. 
#   x = -74.26877975463867
#   y = 40.600486274654804
# 2.ne
#   x = -74.25178527832031
#   y = 40.600486274654804
# 3.sw
#   x = -74.26877975463867
#   y = 40.487692978918865
# 4.
#   x = -74.25178527832031
#   y = 40.487692978918865
# 
#   1---2ne
#   |  F  |
#   |  S  |
#   3sw---4


namespace :fsq do
  
  desc "Parse NY from FS" 
  task :parse_ny => :environment do
    
    require 'digest/md5'
    checksum = Digest::MD5.new.hexdigest
    
    lng_x1 = -74.26877975463867
    lng_x2 = -74.25178527832031
    
    lat_y1 = 40.600486274654804
    lat_y2 = 40.487692978918865 
    
    n = 10
    step_lng_x = (((lng_x2).abs - (lng_x1).abs)).abs / n
    step_lon_y = (((lat_y1).abs - (lat_y2).abs)).abs / n
    
    client = Foursquare2::Client.new(:client_id => $client_id, :client_secret => $client_secret)
    
    (0..n).step(step_lng_x) do |k|
      sw_x = lng_x1 + step_lng_x * k
      ne_x = lng_x1 + step_lng_x * (k + 1)
      
      (0..n).step(step_lon_y) do |m| 
    
        ne_y = lat_y1 - step_lon_y * m
        sw_y = lat_y1 - step_lon_y * (m + 1)
        p "#{ne_y}, #{ne_x}"       
        fsq_hash = client.search_venues(:ne => "#{ne_y},#{ne_x}", :sw =>"#{sw_y},#{sw_x}", :intent => "browse")
        if (checksum != Digest::MD5.hexdigest(fsq_hash.to_s))
          p fsq_hash
        end
        
        checksum = Digest::MD5.hexdigest(fsq_hash.to_s)
        
      end
    end
    
  end
  
  desc "Recheck location for nil coordinates" 
  task :r_loc => :environment do
    rs = Restaurant.where("lat IS NULL").order(:id)
    rs.each do |r|
      s = Geocoder.search(r.address) unless r.address.nil?
      unless s[0].nil?
        s = s[0].geometry["location"]
        r.lat = s['lat']
        r.lon = s['lng']
        r.save
        p "#{r.id} #{s['lat']} #{s['lng']}"
      else
        p "#{r.id}"
      end
    end
  end
  
  desc "Get Popularity and location from Foursquare" 
  task :update => :environment do
  
    client = Foursquare2::Client.new(:client_id => $client_id, :client_secret => $client_secret)
    i = 0
    Restaurant.order(:id).where('id > 16086').each do |r|
      i+= 1
      category_id = []
      if r.fsq_id.blank? && r.created_at.to_i > Time.parse('2012-02-07 16:30:23').to_i
        
        fsq_hash = client.search_venues(:ll => "#{r.lat},#{r.lon}", :query => r.name) if r.lat && r.lon && r.name
        if fsq_hash && fsq_hash.groups[0].items.count > 0

          unless fsq_hash.categories.blank?
            fsq_hash.categories.each do |v|
              if category = RestaurantCategory.find_by_name(v.name)
                category_id.push(category.id)
              else
                category_id.push(RestaurantCategory.create(:name => v.name).id)
              end
            end
          end
          
          r.fsq_name = fsq_hash.groups[0].items.first.name
          r.fsq_address = fsq_hash.groups[0].items.first.location.address
          r.fsq_lat = fsq_hash.groups[0].items.first.location.lat
          r.fsq_lng = fsq_hash.groups[0].items.first.location.lng
          r.fsq_checkins_count = fsq_hash.groups[0].items.first.stats.checkinsCount
          r.fsq_users_count = fsq_hash.groups[0].items.first.stats.usersCount
          r.fsq_tip_count = fsq_hash.groups[0].items.first.stats.tipCount
          r.fsq_id = fsq_hash.groups[0].items.first.id
          r.restaurant_categories = category_id ? category_id.join(',') : '',
          r.save
          p "#{i} #{r.id}: #{r.fsq_id} #{r.name} #{r.address}"
        else
          fsq_hash = client.search_venues(:ll => "#{r.lat},#{r.lon}", :query => r.name_eng) if r.lat && r.lon && r.name_eng
          if fsq_hash && fsq_hash.groups[0].items.count > 0
            
            unless fsq_hash.categories.blank?
              fsq_hash.categories.each do |v|
                if category = RestaurantCategory.find_by_name(v.name)
                  category_id.push(category.id)
                else
                  category_id.push(RestaurantCategory.create(:name => v.name).id)
                end
              end
            end
            
            r.fsq_name = fsq_hash.groups[0].items.first.name
            r.fsq_address = fsq_hash.groups[0].items.first.location.address
            r.fsq_lat = fsq_hash.groups[0].items.first.location.lat
            r.fsq_lng = fsq_hash.groups[0].items.first.location.lng
            r.fsq_checkins_count = fsq_hash.groups[0].items.first.stats.checkinsCount
            r.fsq_users_count = fsq_hash.groups[0].items.first.stats.usersCount
            r.fsq_tip_count = fsq_hash.groups[0].items.first.stats.tipCount
            r.fsq_id = fsq_hash.groups[0].items.first.id
            r.restaurant_categories = category_id ? category_id.join(',') : '',
            r.save
            p "#{i} #{r.id}: #{r.fsq_id} #{r.name} #{r.address}"
          else
            p "#{i} #{r.id}: FAIL!!! #{r.name} #{r.address}"
          end
        end
      elsif !r.fsq_id.blank?
        if venue = client.venue(r.fsq_id)
        
          unless venue.categories.blank?
            venue.categories.each do |v|
              if category = RestaurantCategory.find_by_name(v.name)
                category_id.push(category.id)
              else
                category_id.push(RestaurantCategory.create(:name => v.name).id)
              end
            end
          end
          
          r.fsq_name = venue.name
          r.fsq_address = venue.location.address
          r.fsq_lat = venue.location.lat
          r.fsq_lng = venue.location.lng
          r.fsq_checkins_count = venue.stats.checkinsCount
          r.fsq_users_count = venue.stats.usersCount
          r.fsq_tip_count = venue.stats.tipCount
          r.restaurant_categories = category_id ? category_id.join(',') : '',
        
          r.save
          p "Update: #{i} #{r.id}: #{r.fsq_id} #{r.name} #{r.address}"
        end
      end
    end
  end
  
end