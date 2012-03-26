# encoding: utf-8
namespace :inst do
  
  require 'oauth'
  require 'json'
  require 'net/http'
  
  task :test => :environment do
    
    #Yelp init
    client_id = 'bda7c4a0258a4dcbac6bde04a3ee0c02'
    client_secret = '07af758244594d769a27724ed2c154c4'
    api_host = 'api.instagram.com'
    
    consumer = OAuth::Consumer.new(client_id, client_secret, {:site => "https://#{api_host}"})
    access_token = OAuth::AccessToken.new(consumer, token, token_secret)
    
    p access_token.get(path).body
    
  end
end

# 16503551.bda7c4a.9cbccad59eb84c15a89a39d1341833a8