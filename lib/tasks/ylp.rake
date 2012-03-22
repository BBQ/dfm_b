# encoding: utf-8
namespace :ylp do
  
  # require 'rubygems'
  require 'oauth'
  
  task :parse, [:path] => :environment do |t, args|

    path = args[:path] ||= "/v2/search?term=restaurants&location=new%20york&limit=20&offset=100"
    
    consumer_key = 'wruDIggh-BKVh06lLz_vfg'
    consumer_secret = '3UDVO5rgz3XprgLgN_on8ER4LTw'
    token = 'PwjDW7SUuVrRAapuq11LQ4-POz4QGq20'
    token_secret = 'jT-2uOAWPMSBHgMvU83MoxrlPmU'

    api_host = 'api.yelp.com'

    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
    access_token = OAuth::AccessToken.new(consumer, token, token_secret)

    p access_token.get(path).body

  end
end