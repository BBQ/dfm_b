# encoding: utf-8
namespace :ylp do
  require 'net/https'
  
  task :get_iiko_specials => :environment do
    http = init_iiko
    access_token = get_iiko_token(http)
    
    restaurants = get_iiko_organization_list(http,access_token) 

    restaurants.each do |r|
      
      specials = get_iiko_specials(http,access_token,r['id'])
    end
    
  end
  
end

def init_iiko
  server = 'api.iiko.net'
  port = '9900'
  
  http = Net::HTTP.new(server, port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
  http
end

def request_iiko(http, url)
  req = Net::HTTP::Get.new(url)
  response = http.request(req)
  data = response.body
  
  data.is_json? ? JSON.parse(data) : data
end

def get_iiko_token(http)  
  url = "/api/0/auth/access_token?user_id=dishfm&user_secret=dishfm"
  request_iiko(http, url).gsub('"', '')
end

def get_iiko_organization_list(http,access_token)  
  url = "/api/0/organization/list?access_token=#{access_token}"
  request_iiko(http, url)
end

def get_iiko_nomenclature(http,access_token,id)  
  url = "/api/0/nomenclature/#{id}?access_token=#{access_token}"
  request_iiko(http, url)
end

def get_iiko_specials(http,access_token,id)  
  url = "/api/0/organization/#{id}/specials?access_token=#{access_token}"
  request_iiko(http, url)
end
