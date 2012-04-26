# encoding: utf-8
class Restaurant < ActiveRecord::Base
  
  has_many :dishes, :dependent => :destroy
  has_many :reviews, :dependent => :destroy
  belongs_to :network
  has_many :dishes, :through => :network 
  
  has_many :restaurant_types, :dependent => :destroy
  has_many :types, :through => :restaurant_types
  has_many :restaurant_images, :dependent => :destroy
  
  has_many :restaurant_cuisines
  has_many :cuisines, :through => :restaurant_cuisines
  has_many :dish_category_order, :dependent => :destroy
  
  has_many :restaurant_tags, :dependent => :destroy
  has_many :tags, :through => :restaurant_tags
  has_many :favourites, :dependent => :destroy
    
  mount_uploader :photo, ImageUploader 
  
  # geocoded_by :geo_address, :latitude  => :lat, :longitude => :lon
  # after_validation :geocode, :if => :address_changed?
  
  def self.add_from_4sq_with_menu(foursquare_venue_id)
    
     dish_category_id = ''
     client = Foursquare2::Client.new(:client_id => $client_id, :client_secret => $client_secret)
     # client = Foursquare2::Client.new(:client_id => 'AJSJN50PXKBBTY0JZ0Q1RUWMMMDB0DFCLGMN11LBX4TVGAPV', :client_secret => '5G13AELMDZPY22QO5QSDPNKL05VT1SUOV5WJNGMDNWGCAESX')
     venue = client.venue(foursquare_venue_id)

     unless r = find_by_fsq_id(foursquare_venue_id)

       category_id = []
       venue.categories.each do |v|
         if category = RestaurantCategory.find_by_name(v.name)
           category_id.push(category.id)
         else
           category_id.push(RestaurantCategory.create(:name => v.name).id)
         end
       end

       if network = Network.find_by_name_and_city(venue.name, venue.location.city)
         network_id = network.id
       else
         network_id = Network.create({:name => venue.name, :city =>venue.location.city}).id
       end
       
      begin
        Timezone::Configure.begin do |c|
          c.username = 'innty'
          c.url = 'api.geonames.org'
        end
        if timezone = Timezone::Zone.new(:latlon => [venue.location.lat.to_f,venue.location.lng.to_f])
          time_zone_offset = ActiveSupport::TimeZone.create(timezone.zone).formatted_offset
        end
      rescue
      end
       
       begin
         if address = Geocoder.search("#{venue.location.lat.to_f},#{venue.location.lng.to_f}")       
           venue.location.address = address[0].address if venue.location.address.blank?
           venue.location.city = address[0].city if venue.location.city.blank?
         end
       rescue
       end

       data = {
         :name => venue.name,
         :address => venue.location.address,
         :city => venue.location.city,
         :lat => venue.location.lat.to_f,
         :lon => venue.location.lng.to_f,
         :fsq_id => venue.id,
         :fsq_lng => venue.location.lng,
         :fsq_lat => venue.location.lat,
         :fsq_checkins_count => venue.stats.checkinsCount,
         :fsq_tip_count => venue.stats.tipCount,
         :fsq_users_count => venue.stats.usersCount,
         :fsq_name => venue.name,
         :fsq_address => venue.location.address,
         :source => 'foursquare',
         :phone => venue.contact.formattedPhone,
         :restaurant_categories => category_id.join(','),
         :network_id => network_id,
         :time_zone_offset => time_zone_offset ||= "00:00"
       }

       if r = create(data)
         client.venue_menu(foursquare_venue_id).each do |m|
           
           cat_ord = 0
           m.entries.fourth.second.items.each do |i|

             if dish_category = DishCategory.find_by_name(i.name)
               dish_category_id = dish_category.id
             else
               dish_category_id = DishCategory.create({:name => i.name}).id
             end

             cat_ord += 1
             DishCategoryOrder.create({
               :restaurant_id => r.id, 
               :network_id =>  r.network_id,
               :dish_category_id => dish_category_id,
               :order => cat_ord
             })

             i.entries.third.second.items.each do |d|  

               if d.prices
                 if price = /(.)(\d+\.\d+)/.match(d.prices.first)
                   price = price[2]
                   currency = /(.)(\d+\.\d+)/.match(d.prices.first)[1]
                 else
                   price = /(.)(\d+\.\d+)/.match(d.prices.second)[2]
                   currency = /(.)(\d+\.\d+)/.match(d.prices.second)[1]
                 end
               end

               data = {
                 :network_id => r.network_id,
                 :name => d.name,
                 :price => price ||= 0,
                 :currency => currency ||= '',
                 :description => d.description,
                 :dish_category_id => dish_category_id,
               }
               Dish.create(data)

             end
           end
         end

         system "rake tags:match_dishes NETWORK_ID='#{r.network_id}' &"
         system "rake tags:match_rest NETWORK_ID='#{r.network_id}' &"

       end
     end
     r
  end
  
  def self.search_by_tag_id(id)
    where("restaurants.id IN (SELECT restaurant_id FROM restaurant_tags WHERE tag_id = ?)", id)
  end
  
  def self.bill(bill)
    bill_array = []
    bill_array.push('bill = "до 500 руб"') if bill[0] == '1'
    bill_array.push('bill = "500 - 1000 руб"') if bill[1] == '1'
    bill_array.push('bill = "1000 - 2000 руб"') if bill[2] == '1'
    bill_array.push('bill = "2000 - 5000 руб"') if bill[3] == '1'
    bill_array.push('bill = "более 5000 руб"') if bill[4] == '1'
    where(bill_array.join(' OR '))
  end
  
  def self.search_by_word(keyword)
    ids = {
      1 => ['салат','salad','салатик'],
      2 => ['soup','суп','супы','супчик','супчики','супец'],
      3 => ['pasta','паста','пасты','спагетти'],
      4 => ['pizza','пицца','пиццы'],
      5 => ['burger','бургер'],
      6 => ['noodles','лапша'],
      7 => ['risotto','ризотто'],
      8 => ['rice','рис'],
      9 => ['steak','стейк','стэйк'],
      10 => ['sushi & rolls','суши и роллы','суши','sushi','ролл','сашими'],
      11 => ['desserts','десерт','торт','пирожные','пирожное','выпечка','мороженое','пирог','сладости','сорбет'],
      12 => ['drinks','напитки','напиток'],
      13 => ['meat','мясо','мясное'],
      14 => ['fish','рыба','морепродукты','креветки','мидии','форель','треска','карп','моллюски','устрицы','сибас','лосось','судак'],
      15 => ['vegetables','овощи','овощь']
    }
    
    id = 0
    keyword.downcase!
    
    ids.each {|k,v| id = k if v.include?(keyword)}            
    if id.blank? && tag = Tag.find_by_name(keyword)
      id = tag.id
    end
    
    if id > 0
      where('restaurants.id IN (SELECT restaurant_id FROM restaurant_tags WHERE tag_id = ?)', id)
    else
      where("restaurants.network_id IN ( SELECT DISTINCT network_id FROM dishes WHERE 
                dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE LOWER(dish_categories.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
                OR 
                dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE LOWER(dish_types.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
                OR
                dishes.dish_subtype_id IN (SELECT DISTINCT id FROM dish_subtypes WHERE LOWER(dish_subtypes.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
                OR
                LOWER(dishes.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]'
                OR
                LOWER(restaurants.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]'
              )")
    end
  end
  
  def geo_address
    [city, address].compact.join(', ').gsub(/ТРЦ.*|ТЦ.*|ТК.*|ТДК.*|\(.*|Бизнес.*|к\/т.*|СКК.*|МО,|гостиница.*/, '')
  end
    
  def as_json(options={})
    self[:address] = "#{address}, #{city}" unless city.nil?
    self[:rating] = self.network.rating
    self[:votes] = self.network.votes
    self[:fsq_id] = self.fsq_id || ''
        
    super(:only => [:id, :bill, :name, :address, :rating, :votes, :lat, :lon, :network_id, :fsq_id, :fsq_checkins_count], :methods => [:has_menu, :thumb, :categories])
  end
  
  def favourite(id)
    id
  end
  
  def has_menu
    self.dishes.count > 0 ? 1 : 0
  end
  
  def categories
    c = []
    restaurant_categories.split(',').each do |cid|
      if rc = RestaurantCategory.find_by_id(cid)
        c.push(rc.name)
      end
    end
    
    c.join(', ')
  end
  
  def find_image
    
    if restaurant_image = RestaurantImage.select([:id, :photo]).find_by_restaurant_id(id)
      photo = restaurant_image.photo
            
    elsif dish = Dish.select([:id, :photo]).where("photo IS NOT NULL AND network_id = ?", network_id).order('rating DESC, votes DESC').first
      photo = dish.photo
    
    elsif review = Review.select([:id, :photo]).where("photo IS NOT NULL AND restaurant_id = ?", id).order('count_likes DESC').first
      photo = review.photo
    
    end
    photo
  end
  
  def thumb
    find_image && find_image.iphone.url != '/images/noimage.jpg' ? find_image.p120.url  : ''
  end
  
  def self.near(lat, lon, rad = 1)
    where("((ACOS(
    	SIN(lat * PI() / 180) * SIN(? * PI() / 180) + 
    	COS(lat * PI() / 180) * COS(? * PI() / 180) * 
    	COS((? - lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344 <= ?", lat, lat, lon, rad)
  end
  
  def self.by_distance(lat, lon)
    order("((ACOS(
      SIN(#{lat} * PI() / 180) * SIN(lat * PI() / 180) +
      COS(#{lat} * PI() / 180) * COS(lat * PI() / 180) * 
      COS((#{lon} - lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344")
  end

end
