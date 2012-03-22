# encoding: utf-8
namespace :ylp do
  
  # require 'rubygems'
  require 'oauth'
  
  task :parse, [:path] => :environment do |t, args|
    
    #Yelp init
    consumer_key = 'wruDIggh-BKVh06lLz_vfg'
    consumer_secret = '3UDVO5rgz3XprgLgN_on8ER4LTw'
    token = 'PwjDW7SUuVrRAapuq11LQ4-POz4QGq20'
    token_secret = 'jT-2uOAWPMSBHgMvU83MoxrlPmU'
    api_host = 'api.yelp.com'
    
    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
    access_token = OAuth::AccessToken.new(consumer, token, token_secret)
    
    n = 2 # number of parts devided
    limit = 1000 # places limit
    offset = 0
    
    # get sw and ne bounds from google maps api or type it in 
    # New York
    # http://maps.googleapis.com/maps/api/geocode/json?address=New%20York%20city&sensor=true
    
    x1 = '-74.2590879' # sw_longitude 
    x2 = '-73.700272' # ne_longitude
    
    y1 = '40.495908' # sw_latitude
    y2 = '40.9152413'# ne_latitude
    
    nX = (x2 - x1)/n
    nY = (y2 - y1)/n 
    
    n.times do
      sw_n_longitude = x1
      ne_n_longitude = sw_n_longitude + nX
      
      sw_n_latitude = y2
      ne_n_latitude = sw_n_latitude - nY
    
      bounds = "#{sw_n_latitude},#{sw_n_longitude}|#{ne_n_latitude},#{ne_n_longitude}"
      path = args[:path] ||= "/v2/search?term=restaurants&limit=#{limit}&offset=#{offset}&bounds=#{bounds}"
      p access_token.get(path).body
        
      x1 = ne_n_longitude
      y1 = ne_n_latitude
    end
    
  end
end