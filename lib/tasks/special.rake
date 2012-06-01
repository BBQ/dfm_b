# encoding: utf-8
require 'net/https'

task :get_iiko_specials => :environment do
  http = init_iiko
  access_token = get_iiko_token(http)

  get_iiko_organization_list(http,access_token) .each do |r|  
    get_iiko_specials(http,access_token,r['id']).each do |s|
      
      r['contact']['phone'] = r['contact']['phone'].gsub('+7 (', '+7(').gsub(' ', '-')
      Special.create(iiko_data(r,s))
      
    end
  end
  
end

def iiko_data(r,s)
  r_id = get_restaurant_id(r)
  data = {
    :name => s['name'],
    :description => s['description'],
    :restaurant_id => r_id || 0,
    :address => r['contact']['location'],
    :phone => r['contact']['phone'],
    :url => s['url'],
    :date_start => s['start'],
    :date_end => s['end'],
    :out_id => s['organizationId'],
    # :remote_photo_url => s['imageUrl'],
    :partner => 'iiko' 
  }
end

  
def get_restaurant_id(r)
 if restaurant = Restaurant.find_by_name_and_phone(r['name'],r['contact']['phone'])
   r_id = restaurant.id
 else
   
   city = 'Moscow'
  if network = Network.find_by_name_and_city(r['name'], city)
    n_id = network.id
  else
    network = Network.create(:name => r['name'], :city => city)
    n_id = network.id
  end
   
  data = {
    :name => r['name'],
    :address => r['contact']['location'],
    :phone => r['contact']['phone'],
    :city => city,
    :description => r['description'],
    :web => r['homePage'],
    # :remote_photo_url => r['logo'],
    :network_id => n_id
  } 
  Restaurant.create(data)
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
