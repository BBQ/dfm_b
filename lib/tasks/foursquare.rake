# encoding: utf-8

# NY 
# 1. 
#   x = -74.26877975463867
#   y = 40.600486274654804
# 2.
#   x = -74.25178527832031
#   y = 40.600486274654804
# 3.
#   x = -74.26877975463867
#   y = 40.487692978918865
# 4.
#   x = -74.25178527832031
#   y = 40.487692978918865
# 
#   1-----2
#   |  F  |
#   |  S  |
#   3-----4


namespace :fsq do
  
  desc "Parse NY from FS" 
  task :parse_ny => :environment do
    
    lng_x1 = -74.26877975463867
    lng_x2 = -74.25178527832031
    
    lat_y1 = 40.600486274654804
    lat_y2 = 40.487692978918865 
    
    n = 100
    step_lng_x = abs(lng_x2 - lng_x1 / n)
    step_lon_y = abs(lat_y1 - lat_y2 / n)
    
    client = Foursquare2::Client.new(:client_id => @client_id, :client_secret => @client_secret)
    
    (0..n).step(step_lng_x) do |k|
      
      lng = lng_x1 + step_lng_x * k
      (0..n).step(step_lon_y) do |m|
        
        lat = lat_y1 - step_lon_y * m
        p fsq_hash = client.search_venues(:ll => "#{lat},#{lng}")
      
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
  task :get_info => :environment do
  
    client = Foursquare2::Client.new(:client_id => @client_id, :client_secret => @client_secret)
    i = 0
    Restaurant.order(:id).each do |r|
      i+= 1
      if r.fsq_id.blank?
        fsq_hash = client.search_venues(:ll => "#{r.lat},#{r.lon}", :query => r.name) if r.lat && r.lon && r.name
    
        if fsq_hash && fsq_hash.groups[0].items.count > 0
          r.fsq_name = fsq_hash.groups[0].items.first.name
          r.fsq_address = fsq_hash.groups[0].items.first.location.address
          r.fsq_lat = fsq_hash.groups[0].items.first.location.lat
          r.fsq_lng = fsq_hash.groups[0].items.first.location.lng
          r.fsq_checkins_count = fsq_hash.groups[0].items.first.stats.checkinsCount
          r.fsq_users_count = fsq_hash.groups[0].items.first.stats.usersCount
          r.fsq_tip_count = fsq_hash.groups[0].items.first.stats.tipCount
          r.fsq_id = fsq_hash.groups[0].items.first.id
          r.save
          p "#{i} #{r.fsq_id} #{r.name} #{r.address}"
        else
          fsq_hash = client.search_venues(:ll => "#{r.lat},#{r.lon}", :query => r.name_eng) if r.lat && r.lon && r.name_eng
          if fsq_hash && fsq_hash.groups[0].items.count > 0
            r.fsq_name = fsq_hash.groups[0].items.first.name
            r.fsq_address = fsq_hash.groups[0].items.first.location.address
            r.fsq_lat = fsq_hash.groups[0].items.first.location.lat
            r.fsq_lng = fsq_hash.groups[0].items.first.location.lng
            r.fsq_checkins_count = fsq_hash.groups[0].items.first.stats.checkinsCount
            r.fsq_users_count = fsq_hash.groups[0].items.first.stats.usersCount
            r.fsq_tip_count = fsq_hash.groups[0].items.first.stats.tipCount
            r.fsq_id = fsq_hash.groups[0].items.first.id
            r.save
            p "#{i} #{r.fsq_id} #{r.name} #{r.address}"
          else
            p "#{i} FAIL!!! #{r.name} #{r.address}"
          end
        end
      else
        venue = client.venue(r.fsq_id)
        
        r.fsq_name = venue.name
        r.fsq_address = venue.location.address
        r.fsq_lat = venue.location.lat
        r.fsq_lng = venue.location.lng
        r.fsq_checkins_count = venue.stats.checkinsCount
        r.fsq_users_count = venue.stats.usersCount
        r.fsq_tip_count = venue.stats.tipCount
        
        r.save
        p "Update: #{i} #{r.fsq_id} #{r.name} #{r.address}"
      end
    end
  end
  
end