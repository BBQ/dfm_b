# encoding: utf-8
namespace :inst do
  
  require 'oauth'
  require 'json'
  require 'net/http'
  require 'net/https'
  require 'openssl'
  require 'nokogiri'
  require "uri"
  
  # Google Capture link
  # https://www.google.com/recaptcha/api/noscript?k=6Ld8RcESAAAAAEo6_M9BjluesU7nWtdKmhIeU-jD
  
  task :reg => :environment do
    url = 'http://instagr.am/developer/register/'
    https = 'https://instagr.am'
    
    headers = {
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Charset" => "windows-1251,utf-8;q=0.7,*;q=0.7",
      "Accept-Language" => "ru-ru,ru;q=0.8,en-us;q=0.5,en;q=0.3",
      "Connection" => "keep-alive",
      "Cookie" => "",
      "Host" => "instagr.am",
      "Referer" => "",
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.100 Safari/534.30"
    }

    1.times do
      links = [] 

      document = Nokogiri::HTML(open(url))
      document.css('a').each {|link| links.push(link['href']) if link.text == 'register'}
      
      headers["Referer"] = url
      url = https+links[0]
      reg_page = open(url, headers)
            
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri.request_uri)
      
      form_data = {
        'email' => 'inienineinf333@nm.ru',
        'username' => 'we_aerfe_2012_3',
        'password' => 'iddqd',
        'password_confirm' => 'iddqd',
        'recaptcha_challenge_field' => '03AHJ_VussrUmWafj1HnxFyJvz0giQZ2OEyvoxE5PsT8kcZnjovc_1hVg6bbN9HNRhwQ96_RUdt1ebYrC8VtIYd2esZzfzY11d6d6fBAaDYqA8OpKKQw9wbzJ29_yX_9UF_xCrXgvukHoP',
        'recaptcha_response_field' => 'manual_challenge',
        'csrfmiddlewaretoken' => /csrftoken=(.*?);/.match(reg_page.meta['set-cookie'])[1]        
      }
      
      request.set_form_data(form_data)
      
      request["Accept"] = headers["Accept"]
      request["Accept-Charset"] = headers["Accept-Charset"]
      request["Accept-Language"] = headers["Accept-Language"]
      request["Connection"] = headers["Connection"]
      request["Cookie"] = reg_page.meta['set-cookie']
      request["Host"] = headers["Host"]
      request["Referer"] = url
      request["User-Agent"] = headers["User-Agent"]

      response = http.request(request) {|res|
          puts res.body
        }
      # p Nokogiri::HTML(response)
      
    end
  end

end

# 16503551.bda7c4a.9cbccad59eb84c15a89a39d1341833a8