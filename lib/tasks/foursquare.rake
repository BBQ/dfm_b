# encoding: utf-8
namespace :fsq do
  
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
    Restaurant.where("fsq_lng IS NULL").each do |r|
      i+= 1
      fsq_hash = client.search_venues(:ll => "#{r.lat},#{r.lon}", :query => r.name) if r.lat && r.lon && r.name
    
      if fsq_hash && fsq_hash.groups[0].items.count > 0
        r.fsq_name = fsq_hash.groups[0].items.first.name
        r.fsq_address = fsq_hash.groups[0].items.first.location.address
        r.fsq_lat = fsq_hash.groups[0].items.first.location.lat
        r.fsq_lng = fsq_hash.groups[0].items.first.location.lng
        r.fsq_checkins_count = fsq_hash.groups[0].items.first.stats.checkinsCount
        r.fsq_users_count = fsq_hash.groups[0].items.first.stats.usersCount
        r.fsq_tip_count = fsq_hash.groups[0].items.first.stats.tipCount
        r.save
        p "#{i} #{r.name} #{r.address}"
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
          r.save
          p "#{i} #{r.name} #{r.address}"
        else
          p "#{i} FAIL!!! #{r.name} #{r.address}"
        end
      end
    end
  end
  
end