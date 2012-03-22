class Delivery < ActiveRecord::Base
  has_many :dish_deliveries
  
  has_many :deliveries_tags, :dependent => :destroy
  has_many :tags, :through => :deliveries_tags
  
  def self.add_from_4sq_with_menu(foursquare_venue_id)
    
     dish_category_id = ''
     client = Foursquare2::Client.new(:client_id => $client_id, :client_secret => $client_secret)
     venue = client.venue(foursquare_venue_id)

     unless r = find_by_fsq_id(foursquare_venue_id)
       unless r = Delivery.find_by_name_and_city(venue.name, venue.location.city)
         
         data = {
           :name => venue.name,
           :address => venue.location.address,
           :city => venue.location.city,
           :lat => venue.location.lat.to_f,
           :lon => venue.location.lng.to_f,
           :fsq_id => venue.id,
           # :fsq_lng => venue.location.lng,
           # :fsq_lat => venue.location.lat,
           # :fsq_checkins_count => venue.stats.checkinsCount,
           # :fsq_tip_count => venue.stats.tipCount,
           # :fsq_users_count => venue.stats.usersCount,
           # :fsq_name => venue.name,
           # :fsq_address => venue.location.address,
           :source => 'foursquare',
           :phone => venue.contact.formattedPhone,
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
               DishDeliveryCategoryOrder.create({
                 :delivery_id => r.id, 
                 :dish_category_id => dish_category_id,
                 :order => cat_ord
               })

               i.entries.third.second.items.each do |d|  

                 if d.prices 
                   price = /(.)(\d+\.\d+)/.match(d.prices.first)[2]
                   currency = /(.)(\d+\.\d+)/.match(d.prices.first)[1]
                 end

                 data = {
                   :delivery_id => r.id,
                   :name => d.name,
                   :price => price ||= 0,
                   :currency => currency ||= '',
                   :description => d.description,
                   :dish_category_id => dish_category_id,
                 }
                 DishDelivery.create(data)

               end
             end
           end

           system "rake tags:match_dishes NETWORK_ID='#{r.id}' TYPE='delivery' &"
           system "rake tags:match_rest NETWORK_ID='#{r.id} TYPE='delivery' &"

         end
       end
       
     end
     r
  end
  
  def find_image
    unless photo
      
      if dish = DishDelivery.select([:id, :photo]).where("photo IS NOT NULL AND delivery_id = ?", id).order('rating DESC, votes DESC').first
        photo = dish.photo
      
      elsif review = Review.select([:id, :photo]).where("restaurant_id = ? AND rtype = 'delivery'", id).order('count_likes DESC').first
        photo = review.photo
      
      end
    end
    
    photo
  end
  
  def thumb
    find_image && find_image.p120.url != '/images/noimage.jpg' ? find_image.p120.url  : ''
  end
  
end
