# encoding: utf-8
class API < ActiveRecord::Base

  def self.get_reviews(user_id, dish_id)
    # Coming soon
  end
  
  def self.get_dish(user_id, dish_id)
    
    if dish = Dish.select([:id, :dish_subtype_id, :rating, :network_id, :votes, :dish_type_id, :name, :description, :price, :created_at, :count_likes, :count_comments, :photo]).find_by_id(dish_id)
      
      user_review = Review.select(:rating).find_by_dish_id_and_user_id(dish.id,user_id) if user_id
      subtype = DishSubtype.find_by_id(dish.dish_subtype_id)
      
      top_expert_id = (Review.where('dish_id = ?', dish.id).group('user_id').count).max[0] if Review.find_by_dish_id(dish.id)
      if user = User.select([:id, :name, :facebook_id]).find_by_id(top_expert_id)
        top_expert = {
          :user_name => user.name,
          :user_photo => user.user_photo,
          :user_id => user.id
        }
      end
    
      review_data = []
      user = User.select([:id, :name, :photo, :facebook_id]).find_by_id(1)
      unless dish.photo.blank?
        data = {
          :review_id => dish.id,
          :created_at => dish.created_at.to_time.to_i,
          :text => 'фото предоставлено рестораном',
          :dish_id => dish.id,
          :dish_name => dish.name,
          :dish_votes => dish.votes,
          :restaurant_id => dish.network.restaurants.first.id,    
          :restaurant_name => dish.network.name,
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
      dish.reviews.each {|r| review_data.push(r.format_review_for_api(user_id))}  
          
      restaurants = []
      dish.network.restaurants.each do |restaurant|
        restaurants.push({
          :id => restaurant.id,
          :address => restaurant.address,
          :phone => restaurant.phone.to_s,
          :working_hours => restaurant.time,
          :lat => restaurant.lat,
          :lon => restaurant.lon,
          :description => restaurant.description.to_s
        })
      end
    
      data = {
        :name => dish.name,
        :current_user_rating => user_review ? user_review.rating : '',
        :photo => dish.find_image && dish.find_image.iphone.url != '/images/noimage.jpg' ? dish.find_image.iphone.url : '',
        :rating => dish.rating,
        :votes => dish.votes,
        :type_name => dish.dish_type ? dish.dish_type.name : '',
        :subtype_name => dish.dish_subtype ? dish.dish_subtype.name : '',
        :restaurant_name => dish.network.name, 
        :restaurant_id => dish.network.restaurants.first.id, 
        :description => dish.description.to_s,
        :price => dish.price,
        :reviews => review_data,
        :top_expert => top_expert ||= nil,
        :restaurants => restaurants,
        :error => {:description => nil, :code => nil}
      }
      data.as_json
    else
      {:error => {:description => 'Dish not found', :code => 108}}.as_json
    end
  end
  
  def self.get_restaurant(id, type, user_id)
    restaurant = type == 'restaurant' ? Restaurant.find_by_id(id) : Restaurant.find_by_network_id(id)   
    if restaurant        
      
      review_data = []
      restaurant.network.reviews.each {|r| review_data.push(r.format_review_for_api(user_id))}  
      
      restaurants = []
      
      restaurant.network.restaurants.each do |restaurant|
          restaurants.push({
            :id => restaurant.id,
            :address => restaurant.address,
            :phone => restaurant.phone.to_s,
            :working_hours => restaurant.time,
            :wifi => restaurant.wifi.to_i,
            :cc => restaurant.cc == false ? 0 : 1,
            :cuisines => restaurant.cuisines.map{|k| k.name}.join(', '),
            :terrace => restaurant.terrace == false ? 0 : 1,
            :lat => restaurant.lat,
            :lon => restaurant.lon,
            :description => restaurant.description.to_s
          })
      end
      
      best_dishes = []
      
      restaurant.network.dishes.select('DISTINCT id, name, photo, rating, votes, dish_type_id').order("(dishes.rating - 3)*dishes.votes DESC, dishes.photo DESC").where("photo IS NOT NULL OR rating > 0").each do |dish|
          best_dishes.push({
            :id => dish.id,
            :name => dish.name,
            :photo => dish.image_sd,
            :rating => dish.rating,
            :votes => dish.votes
          })
      end
      
      top_expert_id = Review.where('network_id = ?', restaurant.network_id).group('user_id').count.max_by{|k,v| v}[0] if restaurant.network.reviews.count > 0
      if user = User.find_by_id(top_expert_id)
        top_expert = {
          :user_name => user.name,
          :user_photo => user.user_photo,
          :user_id => user.id
        }
      end
            
      better_restaurants = Restaurant.where('restaurants.fsq_checkins_count >= ?', restaurant.fsq_checkins_count).count.to_f
      popularity = (100 * better_restaurants / Restaurant.where('restaurants.fsq_checkins_count > 0').count.to_f).round(0)
      
      popularity = case popularity
        when 0..33 then "Above average"
        when 34..66 then "Average"
        when 67..100 then "Below average"
        else ''
      end
      
      data = {
          :network_ratings => restaurant.network.rating,
          :network_reviews_count => restaurant.network.reviews.count,
          :popularity => popularity,
          :restaurant_name => restaurant.name,
          :reviews => review_data,
          :best_dishes => best_dishes ||= '',
          :top_expert => top_expert ||= nil,
          :restaurant => {
              :image_sd => restaurant.find_image && restaurant.find_image.iphone.url != '/images/noimage.jpg' ? restaurant.find_image.iphone.url : '',
              :image_hd => restaurant.find_image && restaurant.find_image.iphone_retina.url != '/images/noimage.jpg' ? restaurant.find_image.iphone_retina.url : '',
              :description => "#{restaurant.restaurant_category.name ||= ''}, #{restaurant.description ||= ''}"
          },
          :restaurants => restaurants,
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
