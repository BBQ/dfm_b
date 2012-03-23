# encoding: utf-8
namespace :ylp do
  
  require 'oauth'
  require 'json'
  require 'net/http'
  
  task :parse, [:path] => :environment do |t, args|
    
    #Yelp init
    consumer_key = 'wruDIggh-BKVh06lLz_vfg'
    consumer_secret = '3UDVO5rgz3XprgLgN_on8ER4LTw'
    token = 'PwjDW7SUuVrRAapuq11LQ4-POz4QGq20'
    token_secret = 'jT-2uOAWPMSBHgMvU83MoxrlPmU'
    api_host = 'api.yelp.com'
    
    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
    access_token = OAuth::AccessToken.new(consumer, token, token_secret)
    
    n = 60 # number of parts devided
    
    # get sw and ne bounds from google maps api or type it in 
    # New York
    # http://maps.googleapis.com/maps/api/geocode/json?address=New%20York%20city&sensor=true
    
    x1 = -74.259087 # sw_longitude 
    x2 = -73.700272 # ne_longitude
    
    y1 = 40.495908 # sw_latitude
    y2 = 40.915241 # ne_latitude
    
    nX = (x2 - x1)/n
    nY = (y2 - y1)/n 
    
    n.times do
      sw_n_longitude = x1
      ne_n_longitude = sw_n_longitude + nX
      
      sw_n_latitude = y2
      ne_n_latitude = sw_n_latitude - nY
    
    #   string = Net::HTTP.get('www.yelp.com', '/search/snippet?attrs=&cflt=&cut=1&find_desc=&find_loc=Hastings-on-Hudson,+NY+10706&l=g%3A-73.84273767471313,40.97358006004789,-73.8384461402893,40.97682014054761&mapsize=large&parent_request_id=1336b66ac168282e&rpp=10&show_filters=0&sortby=best_match&start=0')
    # '  http://www.yelp.com/search?attrs=&cflt=&find_desc=restaurants&find_loc=New+York%2C+NY&l=g%3A-74.35066223144531%2C40.79613778833378%2C-74.21333312988281%2C40.90001986856228&parent_request_id=1336b66ac168282e&rpp=40&sortby=best_match&start=40"'
    # 
      bounds = "#{sw_n_longitude},#{sw_n_latitude}%7C#{ne_n_longitude},#{ne_n_latitude}"
      path = args[:path] ||= "/v2/search?term=restaurants&offset=#{offset}&bounds=#{bounds}"
      # p access_token.get(path).body
        
      x1 = ne_n_longitude
      y1 = ne_n_latitude
    end
    
  end
end