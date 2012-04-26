# encoding: utf-8
class API < ActiveRecord::Base
  
  def self.get_dish(user_id, dish_id, type)
    
    if type == 'home_cooked'
      dish = HomeCook.select([:top_user_id, :id, :dish_subtype_id, :rating, :votes, :dish_type_id, :name, :description, :created_at, :count_likes, :count_comments, :photo]).find_by_id(dish_id)
    elsif type == 'delivery'
      dish = DishDelivery.select([:top_user_id, :id, :dish_subtype_id, :rating, :votes, :dish_type_id, :name, :description, :created_at, :count_likes, :count_comments, :photo, :delivery_id, :price, :currency]).find_by_id(dish_id)      
    else
      dish = Dish.select([:top_user_id, :id, :dish_subtype_id, :rating, :network_id, :votes, :dish_type_id, :name, :description, :price, :currency, :created_at, :count_likes, :count_comments, :photo]).find_by_id(dish_id)
    end
    
    if !dish.nil?
      
      user_review = Review.select(:rating).find_by_dish_id_and_user_id(dish.id,user_id) if user_id
      subtype = DishSubtype.find_by_id(dish.dish_subtype_id)
      
      if user = User.select([:id, :name, :facebook_id]).find_by_id(dish.top_user_id)
        top_expert = {
          :user_name => user.name,
          :user_photo => user.user_photo,
          :user_id => user.id
        }
      end
    
      review_data = []
      
      if type != 'home_cooked'
        user = User.select([:id, :name, :photo, :facebook_id]).find_by_id(1)
        unless dish.photo.blank?
          data = {
            :review_id => dish.id,
            :created_at => dish.created_at.to_time.to_i,
            :text => 'фото предоставлено рестораном',
            :dish_id => dish.id,
            :dish_name => dish.name,
            :dish_votes => dish.votes,
            :restaurant_id => type == 'delivery' ? dish.delivery.id : dish.network.restaurants.first.id,    
            :restaurant_name => type == 'delivery' ? dish.delivery.name : dish.network.name,
            :user_id => user.id,
            :user_name => user.name,
            :user_photo => user.user_photo,
            :likes => dish.count_likes ||= 0,
            :comments => dish.count_comments ||= 0,
            :review_rating => dish.rating ||= 0,
            :dish_rating => dish.rating ||= 0,
            :image_sd => dish.photo.iphone.url,
            :image_hd => dish.photo.iphone_retina.url,
            :liked => user_id && DishLike.find_by_user_id_and_dish_id(user_id, dish.id) ? 1 : 0,
            :self_review => 1
          }
          review_data.push(data)
        end
      end
      
      dish.reviews.each {|r| review_data.push(r.format_review_for_api(user_id))}  
     
      if type != 'home_cooked' && type != 'delivery'
        restaurants = []
        dish.network.restaurants.each do |restaurant|
          restaurants.push(
            :id => restaurant.id,
            :address => restaurant.address,
            :phone => restaurant.phone.to_s,
            :working_hours => restaurant.time,
            :lat => restaurant.lat,
            :lon => restaurant.lon,
            :description => restaurant.description.to_s,
            :fsq_checkins_count => restaurant.fsq_checkins_count,
            :rating => restaurant.rating,
            :votes => restaurant.votes,
            :thumb => restaurant.thumb,
            :type => nil            
          )
        end
      elsif type == 'delivery'
        restaurants = []
        restaurant = dish.delivery
        
        restaurants.push(
          :id => restaurant.id,
          :address => restaurant.address,
          :phone => restaurant.phone.to_s,
          :working_hours => restaurant.time,
          :lat => restaurant.lat,
          :lon => restaurant.lon,
          :description => restaurant.description.to_s,
          :type => 'delivery'
        )
      end
      
      if type == 'delivery'
        restaurant = dish.delivery
      elsif type != 'home_cooked'
        restaurant = dish.network.restaurants.first
      end

      favourite = Favourite.find_by_user_id_and_dish_id(user_id, dish.id) ? 1 : 0      
      data = {
        :name => dish.name,
        :current_user_rating => user_review ? user_review.rating : '',
        :photo => dish.find_image && dish.find_image.iphone.url != '/images/noimage.jpg' ? dish.find_image.iphone.url : '',
        :rating => dish.rating,
        :votes => dish.votes,
        :type_name => dish.dish_type ? dish.dish_type.name : '',
        :subtype_name => dish.dish_subtype ? dish.dish_subtype.name : '',
        :restaurant_name => type == 'home_cooked' ? '' : restaurant.name, 
        :restaurant_id => type == 'home_cooked' ? 0 : restaurant.id, 
        :description => dish.description.to_s,
        :price => type == 'home_cooked' ? 0 : dish.price,
        :currency => type == 'home_cooked' ? 0 : dish.currency,
        :reviews => review_data,
        :top_expert => top_expert ||= nil,
        :restaurants => restaurants,
        :favourite => favourite,
        :error => {:description => nil, :code => nil}
      }  
      data.as_json
      
    else
      {:error => {:description => 'Dish not found', :code => 7}}.as_json
    end
  end
  
  def self.get_restaurant(id, data_type, user_id, type = nil)
    
    if type == 'delivery'
      restaurant = Delivery.find_by_id(id)
    else
      restaurant = data_type == 'restaurant' ? Restaurant.find_by_id(id) : Restaurant.find_by_network_id(id)   
    end
    
    if restaurant        
      
      review_data = []
      data_r = type == 'delivery' ? restaurant : restaurant.network
      data_d = type == 'delivery' ? restaurant.dish_deliveries : restaurant.network.dishes
      data_r.reviews.each {|r| review_data.push(r.format_review_for_api(user_id))}  
      
      if type != 'delivery'
        restaurants = []
        restaurant.network.restaurants.each do |restaurant|
            restaurants.push(
              :id => restaurant.id,
              :address => restaurant.address,
              :phone => restaurant.phone.to_s,
              :working_hours => restaurant.time,
              :lat => restaurant.lat,
              :lon => restaurant.lon,
              :description => restaurant.description.to_s,
              :fsq_id => restaurant.fsq_id,
              :fsq_checkins_count => restaurant.fsq_checkins_count,
              :rating => restaurant.rating,
              :votes => restaurant.votes,
              :thumb => restaurant.thumb,
            )
        end
      end
      
      best_dishes = []
      
      
      data_d.select('DISTINCT id, name, photo, rating, votes, dish_type_id').order("(rating - 3)*votes DESC, photo DESC").where("photo IS NOT NULL OR rating > 0").each do |dish|
          favourite = Favourite.find_by_user_id_and_dish_id(user_id, dish.id) ? 1 : 0
          best_dishes.push(
            :id => dish.id,
            :name => dish.name,
            :photo => dish.image_sd,
            :rating => dish.rating,
            :votes => dish.votes,
            :type => type,
            :favourite => favourite
          )
      end
      
      if user = User.find_by_id(restaurant.top_user_id)
        top_expert = {
          :user_name => user.name,
          :user_photo => user.user_photo,
          :user_id => user.id
        }
      end
            
      restaurant_categories = []
      if type != 'delivery'
        unless restaurant.restaurant_categories.blank?
          RestaurantCategory.select(:name).where("id in (#{restaurant.restaurant_categories})").each {|r| restaurant_categories.push(r.name)}
        end
      end
      
      rc = []
      if restaurant.bill.to_i > 0
        b = ''
        restaurant.bill.to_i.times {b << '$'}
        rc.push(b)
      end 
      rc.push(restaurant_categories.join(', ')) if restaurant_categories.count > 0
      rc = rc.join(', ') if rc.count > 0
      
      wday = Date.today.strftime("%a").downcase
      open_now = 0
      unless restaurant.send(wday).blank?
        now = Time.now.strftime("%H%M")
        open_now = 1 if now > restaurant.send(wday)[0,5].gsub(':','') && now < restaurant.send(wday)[-5,5].gsub(':','')
      end
      
      description = []
      description.push(restaurant.description) unless restaurant.description.blank?

      description.push("Wi-Fi: #{restaurant.wifi.sub('0','no').sub('1','yes').sub('2','paid')}") unless restaurant.wifi.blank?
      description.push("Accept Credit Card: #{restaurant.cc.to_s.sub('false','no').sub('true','yes')}") unless restaurant.cc.blank?
      description.push("Terrace: #{restaurant.terrace.to_s.sub('false','no').sub('true','yes')}") unless restaurant.terrace.blank?

      description.push("Delivery: #{restaurant.delivery.sub('0','no').sub('1','yes')}") unless restaurant.delivery.blank?           
      description.push("Reservation: #{restaurant.reservation.sub('0','no').sub('1','yes')}") unless restaurant.reservation.blank?
      description.push("Takeaway: #{restaurant.takeaway.to_s.sub('false','no').sub('true','yes')}") unless restaurant.takeaway.blank?      
     
      description.push("Ambience: #{restaurant.ambience}") if restaurant.ambience.to_i != 0
      description.push("Service: waiters") if restaurant.service == true
      description.push("Attire: #{restaurant.attire}") if restaurant.attire.to_i != 0

      description.push("Breakfast: #{restaurant.breakfast.sub(/^0$/,'no').sub(/^1$/,'yes')}") unless restaurant.breakfast.blank?
      description.push("Business lunch: #{restaurant.businesslunch.sub(/^0$/,'no').sub(/^1$/,'yes')}") unless restaurant.businesslunch.blank?
      description.push("Alcohol: #{restaurant.alcohol}") if restaurant.alcohol.to_i != 0

      description.push("Parking: #{restaurant.parking.sub('0','no').sub('1','yes')}") unless restaurant.parking.blank?
      description.push("Music: #{restaurant.music.sub('0','no').sub('1','yes')}") unless restaurant.music.blank?
      description.push("Transit: #{restaurant.transit}") if restaurant.transit.to_i != 0
      
      description.push("Shisha: #{restaurant.chillum.sub('0','no').sub('1','yes')}") unless restaurant.chillum.blank?
      description.push("Noise: #{restaurant.noise}") if restaurant.noise.to_i != 0
      description.push("TV: #{restaurant.tv.to_s.sub('false','no').sub('true','yes')}") unless restaurant.tv.blank?
     
      description.push("Disabled: #{restaurant.disabled.sub('0','no').sub('1','yes')}") unless restaurant.disabled.blank?
      description.push("Caters: #{restaurant.caters.sub('0','no').sub('1','yes')}") unless restaurant.caters.blank?
      
      description.push("Good for meal: #{restaurant.good_for_meal}") if restaurant.good_for_meal.to_i  != 0
      description.push("Good for groups: #{restaurant.good_for_groups.to_s.sub('false','no').sub('true','yes')}") unless restaurant.good_for_groups.blank?      
      description.push("Good For Kids: #{restaurant.good_for_kids.sub('1','yes')}") if restaurant.good_for_kids.to_i  != 0
      
      description.push("Cuisines: #{restaurant.cuisines.map{|k| k.name}.join(', ')}") unless restaurant.cuisines.blank?      

      description = description.join("\n") if description.count > 0                  
      favourite = Favourite.find_by_user_id_and_network_id(user_id, restaurant.network_id) ? 1 : 0
      
      data = {
          :network_ratings => data_r.rating,
          :network_reviews_count => data_r.reviews.count,
          :popularity => type == 'delivery' ? 0 : restaurant.fsq_checkins_count ||= 0,
          :restaurant_name => restaurant.name,
          :reviews => review_data,
          :best_dishes => best_dishes ||= '',
          :top_expert => top_expert ||= nil,
          :open_now => open_now, 
          :restaurant => {
              :image_sd => restaurant.find_image && restaurant.find_image.iphone.url != '/images/noimage.jpg' ? restaurant.find_image.iphone.url : '',
              :image_hd => restaurant.find_image && restaurant.find_image.iphone_retina.url != '/images/noimage.jpg' ? restaurant.find_image.iphone_retina.url : '',
              :description => description ||= ''
          },
          :restaurant_categories => rc ||= '',
          :restaurants => restaurants,
          :type => type,
          :favourite => favourite,
          :error => {:description => '', :code => ''}
      }
    else
       data = {
           :error => {:description => nil, :code => nil}
       } 
    end
    data.as_json
  end
  
end
