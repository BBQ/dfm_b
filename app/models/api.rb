# encoding: utf-8
class API < ActiveRecord::Base

  def self.get_reviews(user_id, dish_id)
    # Coming soon
  end
  
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
          restaurants.push({
            :id => restaurant.id,
            :address => restaurant.address,
            :phone => restaurant.phone.to_s,
            :working_hours => restaurant.time,
            :lat => restaurant.lat,
            :lon => restaurant.lon,
            :description => restaurant.description.to_s,
            :type => nil
          })
        end
      elsif type == 'delivery'
        restaurants = []
        restaurant = dish.delivery
        
        restaurants.push({
          :id => restaurant.id,
          :address => restaurant.address,
          :phone => restaurant.phone.to_s,
          :working_hours => restaurant.time,
          :lat => restaurant.lat,
          :lon => restaurant.lon,
          :description => restaurant.description.to_s,
          :type => 'delivery'
        })
      end
      
      if type == 'delivery'
        restaurant = dish.delivery
      elsif type != 'home_cooked'
        restaurant = dish.network.restaurants.first
      end
    
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
            restaurants.push({
              :id => restaurant.id,
              :address => restaurant.address,
              :phone => restaurant.phone.to_s,
              :working_hours => restaurant.time,
              :cuisines => restaurant.cuisines.map{|k| k.name}.join(', '),
              :wifi => restaurant.wifi.to_i,
              :cc => restaurant.cc == true ? 1 : 0,
              :terrace => restaurant.terrace == true ? 1 : 0,
              :lat => restaurant.lat,
              :lon => restaurant.lon,
              :description => restaurant.description.to_s,
              :fsq_id => restaurant.fsq_id
            })
        end
      end
      
      best_dishes = []
      
      
      data_d.select('DISTINCT id, name, photo, rating, votes, dish_type_id').order("(rating - 3)*votes DESC, photo DESC").where("photo IS NOT NULL OR rating > 0").each do |dish|
          best_dishes.push({
            :id => dish.id,
            :name => dish.name,
            :photo => dish.image_sd,
            :rating => dish.rating,
            :votes => dish.votes,
            :type => type
          })
      end
      
      if user = User.find_by_id(restaurant.top_user_id)
        top_expert = {
          :user_name => user.name,
          :user_photo => user.user_photo,
          :user_id => user.id
        }
      end

      # if type == 'delivery'
      #   better_restaurants = Delivery.where('rating >= ?', restaurant.rating).count.to_f
      #   rating_restaurants = Delivery.where('rating > 0').count.to_f
      # else
      #   better_restaurants = Restaurant.where('restaurants.fsq_checkins_count >= ?', restaurant.fsq_checkins_count).count.to_f
      #   rating_restaurants = Restaurant.where('restaurants.fsq_checkins_count > 0').count.to_f
      # end
      # 
      # if rating_restaurants != 0
      #   popularity = case (100 * better_restaurants / rating_restaurants).round(0)  
      #     
      #     when 0..33 then "Very popular"
      #     when 34..66 then "Popular"
      #     when 67..100 then "Not so popular"
      #   end        
      # else
      #   popularity = "Not so popular"
      #   
      # end
            
      restaurant_categories = []
      if type != 'delivery'
        unless restaurant.restaurant_categories.blank?
          RestaurantCategory.select(:name).where("id in (#{restaurant.restaurant_categories})").each {|r| restaurant_categories.push(r.name)}
        end
      end
      
      data = {
          :network_ratings => data_r.rating,
          :network_reviews_count => data_r.reviews.count,
          :popularity => type == 'delivery' ? 0 : restaurant.fsq_checkins_count,
          :restaurant_name => restaurant.name,
          :reviews => review_data,
          :best_dishes => best_dishes ||= '',
          :top_expert => top_expert ||= nil,
          :restaurant => {
              :image_sd => restaurant.find_image && restaurant.find_image.iphone.url != '/images/noimage.jpg' ? restaurant.find_image.iphone.url : '',
              :image_hd => restaurant.find_image && restaurant.find_image.iphone_retina.url != '/images/noimage.jpg' ? restaurant.find_image.iphone_retina.url : '',
              :description => restaurant.description ||= ''
          },
          :restaurant_categories => restaurant_categories ? restaurant_categories.join(', ') : [],
          :restaurants => restaurants,
          :type => type,
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
