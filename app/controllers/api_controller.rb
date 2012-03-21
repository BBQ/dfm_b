# encoding: utf-8
class ApiController < ApplicationController
  
  before_filter :init_error
  
  def init_error
    $error = {:description => nil, :code => nil}
  end
  
  def set_user_preferences
    if Session.check_token(params[:user_id], params[:token])
      if pref = UserPreference.find_by_user_id(params[:user_id])
        
        params.each do |k,v|     
          pref.send("#{k}=".to_sym, v) if ActiveRecord::Base.connection.column_exists?(:user_preferences, k)
        end
        pref.save
    
      else  
        $error = {:description => 'User Preferences not found', :code => 21}
      end
        
    else
      $error = {:description => 'Params missing', :code => 25}
    end
    
    return render :json => {
      :error => $error
    }
  end
  
  def add_restaurant
    
    if (params[:restaurant][:address] || (params[:restaurant][:lat] && params[:restaurant][:lon]) || params[:restaurant][:web] || params[:restaurant][:phone]) && params[:restaurant][:name] && params[:restaurant][:category]
      
      if restaurant_category = RestaurantCategory.find_by_name(params[:restaurant][:category]) #TODO: make an array with categories not only single one
        params[:restaurant][:restaurant_categories] = restaurant_category.id
      else
        params[:restaurant][:restaurant_categories] = RestaurantCategory.create({:name => params[:restaurant][:category]}).id
      end
      params[:restaurant].delete(:category)
      
      # if n = Network.find_by_name(params[:restaurant][:name])
      #   params[:restaurant][:network_id] = n.id
      # else
      #   n = Network.create({:name => params[:restaurant][:name], :city => params[:restaurant][:city]})
      #   params[:restaurant][:network_id] = n.id
      # end
      
      n = Network.create({:name => params[:restaurant][:name], :city => params[:restaurant][:city]})
      params[:restaurant][:network_id] = n.id
      
      if params[:restaurant][:address]
        r = Geocoder.search("#{params[:restaurant][:address]}")
        unless r.blank?
          if params[:restaurant][:lat].blank? && params[:restaurant][:lon].blank?
            params[:restaurant][:lat] = r[0].geometry['location']['lat']
            params[:restaurant][:lon] = r[0].geometry['location']['lng']
          end
        end
      end
      
      if params[:restaurant][:lat] && params[:restaurant][:lon]
        r = Geocoder.search("#{params[:restaurant][:lat]},#{params[:restaurant][:lon]}")
        unless r.blank?
          if params[:restaurant][:address].blank?
            params[:restaurant][:address] = "#{r[0].address_components[1]['long_name']}, #{r[0].address_components[0]['long_name']}"
          end
        end
      end
      
      unless r.blank?
        if city = r[0].address_components[3]
          if city['long_name'] == 'Moscow'
            params[:restaurant][:city] = city['long_name']
          else
            params[:restaurant][:city] = r[0].address_components[2]['long_name']
          end
        else
          params[:restaurant][:city] = r[0].address_components[1]['long_name']
        end
      end
            
      if rest = Restaurant.create(params[:restaurant])
        r_id = rest.id 
      end
          
    else
      $error = {:description => 'Params missing', :code => 8}
    end
    
    return render :json => {
          :error => $error,
          :restaurant_id => r_id ||= 0
    }
    
  end
  
  def add_social_network_account
    if Session.check_token(params[:user_id], params[:token]) && (params[:access_token] || (params[:oauth_token] && params[:oauth_token_secret]))
      user = User.find_by_id(params[:user_id])
    
      if params[:access_token] && user.facebook_id.blank?
      
        if session = User.authenticate_by_facebook(params[:access_token])          
          if old_user = User.find_by_facebook_id(result["id"])
          
            Review.where(:user_id => old_user.id).each do |d|
              d.user_id = user.id
              d.save
            end
          
            Like.where(:user_id => old_user.id).each do |d|
              d.user_id = user.id
              d.save
            end
          
            Comment.where(:user_id => old_user.id).each do |d|
              d.user_id = user.id
              d.save
            end
          
            Follower.where(:user_id => old_user.id).each do |d|
              d.user_id = user.id
              d.save
            end
            
            Follower.where(:follow_user_id => old_user.id).each do |d|
              d.follow_user_id = user.id
              d.save
            end
            
            rest = Koala::Facebook::GraphAndRestAPI.new(params[:access_token])
            result = rest.get_object("me")

            user.facebook_id = result["id"]
            user.save
            
            old_user.destroy    
          end
          
        end  
      
      elsif params[:oauth_token] && params[:oauth_token_secret] && user.twitter_id.blank?
     
        if client = Twitter::Client.new(:oauth_token => params[:oauth_token], :oauth_token_secret => params[:oauth_token_secret])           
          
          if old_user = User.find_by_twitter_id(client.user.id)
          
            Review.where(:user_id => old_user.id).each do |d|
              d.user_id = user.id
              d.save
            end
          
            Like.where(:user_id => old_user.id).each do |d|
              d.user_id = user.id
              d.save
            end
          
            Comment.where(:user_id => old_user.id).each do |d|
              d.user_id = user.id
              d.save
            end
          
            Follower.where(:user_id => old_user.id).each do |d|
              d.user_id = user.id
              d.save
            end
            
            Follower.where(:follow_user_id => old_user.id).each do |d|
              d.follow_user_id = user.id
              d.save
            end
                        
            user.twitter_id = client.user.id
            user.save
            
            old_user.destroy
          end
          
        end
        
      end
    else
      $error = {:description => 'Params missing', :code => 8}
    end
    
    return render :json => {
          :error => $error
    }
  end
  
  def find_friends
    if params[:user_id] && (params[:access_token] || (params[:oauth_token] && params[:oauth_token_secret]))
      data = []
      
      if (params[:access_token])
        rest = Koala::Facebook::GraphAPI.new(params[:access_token])
        user = rest.get_object("me")

        rest.get_connections("me", "friends").each do |f|
          if user = User.select([:id, :name, :photo, :facebook_id]).find_by_facebook_id(f['id'])
            data.push({
              :id => user.id,
              :name => user.name,
              :photo => user.user_photo,
              :use => 1,
              :twitter => 0,
              :facebook => user.facebook_id.to_s
            })
          else
            data.push({
              :id => 0,
              :name => f['name'],
              :photo => "http://graph.facebook.com/#{f['id']}/picture?type=square",
              :use => 0,
              :twitter => 0,
              :facebook => f['id']
            })
          end
        end
      end
      
      if (params[:oauth_token] && params[:oauth_token_secret])
        if client = Twitter::Client.new(:oauth_token => params[:oauth_token], :oauth_token_secret => params[:oauth_token_secret])

          client.follower_ids.ids.each do |id|
            if user = User.select([:id, :name, :photo, :facebook_id]).find_by_twitter_id(id)
              data.each do |d|
                if d[:id] == user.id
                  d[:twitter] = user.twitter_id.to_s
                  dont_push = 1
                  break
                end
              end
              data.push({
                :id => user.id,
                :name => user.name,
                :photo => user.user_photo,
                :use => 1,
                :twitter => user.twitter_id.to_s,
                :facebook => 0
              }) if dont_push.nil?
            end
          end

          client.friend_ids.ids.each do |id|
            if user = User.select([:id, :name, :photo, :twitter_id]).find_by_twitter_id(id)
              dont_push = 0
              data.each do |d|
                if d[:id] == user.id
                  d[:twitter] = 1
                  dont_push = 1
                  break
                end
              end
              data.push({
                :id => user.id,
                :name => user.name,
                :photo => user.user_photo,
                :use => 1,
                :twitter => user.twitter_id.to_s,
                :facebook => 0
              }) if dont_push != 1
            end
          end
        end      
      end
      
    else
      $error = {:description => 'Params missing', :code => 8}
    end
    return render :json => {
          :users => data,
          :error => $error
    }
  end
  
  def add_push_token
    if params[:token]
      APN::Device.create(:token => params[:token]) unless APN::Device.where(:token => params[:token]).first
    else
      $error = {:description => 'Params missing', :code => 8}
    end
    return render :json => {
          :error => $error
    }
  end
  
  def get_user_following
    if params[:user_id]
      following = []
      User.select([:id, :photo, :name, :facebook_id]).where('id IN (SELECT follow_user_id FROM followers WHERE user_id = ?)', params[:user_id]).each do |f|
        following.push({
          :user_id => f.id,
          :name => f.name,
          :photo => f.user_photo
        })
      end
      followers =  []
      User.select([:id, :photo, :name, :facebook_id]).where('id IN (SELECT user_id FROM followers WHERE follow_user_id = ?)', params[:user_id]).each do |f|
          followers.push({
            :user_id => f.id,
            :name => f.name,
            :photo => f.user_photo
          })
      end
    else
      $error = {:description => 'Params missing', :code => 8}
    end
    
    return render :json => {
          :following => following ||= [],
          :followers => followers ||= [],
          :error => $error
    }
  end
  
  def del_comment
    if params[:comment_id] && Session.check_token(params[:user_id], params[:token])
      if params[:self_review].to_i == 1
        if comment = DishComment.find_by_id_and_user_id(params[:comment_id], params[:user_id])
          comment.delete
        else
          $error = {:description => 'Comment not found', :code => 5}
        end
      else
        if comment = Comment.find_by_id_and_user_id(params[:comment_id], params[:user_id])
          comment.delete
        else
          $error = {:description => 'Comment not found', :code => 5}
        end
      end
    else
        $error = {:description => 'Params missing', :code => 8}
    end
    return render :json => {
          :error => $error
    }
  end
  
  def del_review
    if params[:review_id] && Session.check_token(params[:user_id], params[:token])   
        if review = Review.find_by_id_and_user_id(params[:review_id], params[:user_id])
          review.delete
        else
          $error = {:description => 'Review not found', :code => 5}  
        end
    else
        $error = {:description => 'Params missing', :code => 8}
    end
    return render :json => {
          :error => $error
    }
  end
  
  def authenticate_user
    if params[:provider]
      
      if params[:provider] == 'facebook' && params[:access_token]
        session = User.authenticate_by_facebook(params[:access_token]) 
      elsif params[:provider] == 'twitter' && params[:oauth_token] && params[:oauth_token_secret]
        session = User.authenticate_by_twitter(params[:oauth_token], params[:oauth_token_secret], params[:email])
      end
      
      #Add push token
      if params[:push_token] && session
        if push_token = APN::Device.where(:token => params[:push_token]).first
          if push_token.user_id == 0
            push_token.user_id = session[:user_id]
            push_token.save
          end
        else
          APN::Device.create({:token => params[:push_token], :user_id => session[:user_id]})
        end
      end
      user_preferences = UserPreference.for_user.find_by_user_id session[:user_id] if session
    else
      $error = {:description => 'Parameters missing', :code => 8}
    end
    
    return render :json => {
          :session => session ||= nil,
          :user_preferences => user_preferences ||= nil,
          :error => $error
    }
  end
  
  def follow_user
    if !params[:user_id].blank? && !params[:token].blank? && !params[:follow_user_id].blank?
        if Session.check_token(params[:user_id], params[:token]) && params[:user_id] != params[:follow_user_id]
            if follower = Follower.find_by_user_id_and_follow_user_id(params[:user_id], params[:follow_user_id])
              follower.destroy
              status = 'unfollow'
            elsif user = User.find_by_id(params[:follow_user_id])
              Follower.create({:user_id => params[:user_id], :follow_user_id => params[:follow_user_id]})
              Notification.send(params[:user_id], 'following', params[:follow_user_id])
              status = 'follow'
            else
              $error = {:description => 'user or follower not found', :code => 5}
            end
        end
    else
      $error = {:description => 'Parameters missing', :code => 8}
    end
    
    return render :json => {
      :status => status ||= nil,
      :error => $error
    }
    
  end
  
  def get_dish
    if params[:dish_id]
      return render :json => API.get_dish(params[:user_id], params[:dish_id], params[:type])
    else
      $error = {:description => 'Parameters missing', :code => 8}
      return render :json => {:error => $error}
    end
  end
  
  def get_common_data
    timestamp = Time.at(params[:timestamp].to_i) if params[:timestamp].to_i > 0
            
    keywords = Tag.select("id, name_a as name").where("name_a IN ('salad','soup','pasta','pizza','burger','noodles','risotto','rice','steak','sushi','dessert','drinks','meat','fish','vegetables')")    
    networks = Network.select([:id, :name])
    locations = LocationTip.select([:id, :name])

    return render :json => {
          :types => DishType.format_for_api(timestamp),
          :keywords => timestamp ? keywords.where('updated_at >= ?', timestamp) : keywords.all,
          # :networks => timestamp ? networks.where('updated_at >= ?', timestamp) : networks.all,
          :cities => timestamp ? locations.where('updated_at >= ?', timestamp) : locations.all,
          :tags => Tag.get_all(timestamp),
          :error => $error
    }
  end
  
  def get_restaurant
    if params[:restaurant_id] || params[:network_id]
      if params[:restaurant_id]
        id = params[:restaurant_id]
        type = 'restaurant'
      else
        id = params[:network_id]
        type = 'network'
      end     
      return render :json => API.get_restaurant(id, type, params[:user_id])
    else
      return render :json => {:error => $error}
    end
  end
  
  def get_dishes
    
    if params[:radius].to_f != 0 
      radius = params[:radius].to_f
    else
      radius = 30 if params[:radius] == 'city'
      radius = 40075 if params[:radius] == 'global'
    end
    
    if radius
      
      limit = params[:limit] ? params[:limit].to_i : 25
      offset = params[:offset] ? params[:offset].to_i : 0
    
      lat = params[:lat] ||= '55.753548'
      lon = params[:lon] ||= '37.609239'
    
      restaurants = Restaurant.select(:network_id).near(params[:lat], params[:lon], radius).group(:network_id)
      restaurants = restaurants.bill(params[:bill]) if params[:bill] && params[:bill].length == 5 && params[:bill] != '00000' && params[:bill] != '11111'
    
      networks = []  
      restaurants.each {|r| networks.push(r.network_id)}
      
      if params[:type] == 'home_cooked'
        dishes = HomeCook.select([:id, :name, :rating, :votes, :photo]).order("votes DESC, photo DESC")
      elsif params[:type] == 'delivery'
        dishes = DishDelivery.select([:id, :name, :rating, :votes, :photo, :delivery_id]).order("votes DESC, photo DESC")
      else      
        dishes = Dish.select([:id, :name, :rating, :votes, :photo, :network_id, :fsq_checkins_count]).where("network_id IN (#{networks.join(',')})").order("votes DESC, photo DESC, fsq_checkins_count DESC")
        dishes = dishes.search_by_tag_id(params[:tag_id]) if params[:tag_id].to_i > 0
        dishes = dishes.search(params[:search]) unless params[:search].blank?
      end
      if params[:dish_id] && params[:dish_id].to_i > 0
        
        if params[:type] == 'home_cooked'
          dish = HomeCook.select([:id, :rating]).where(:id => params[:dish_id].to_i)
        elsif params[:type] == 'delivery'
          dish = DishDelivery.select([:id, :rating]).where(:id => params[:dish_id].to_i)
        else
          dish = Dish.select([:id, :rating, :fsq_checkins_count]).where(:id => params[:dish_id].to_i)            
        end
        
        unless dish.nil?
          dish = dish.search_by_tag_id(params[:tag_id]) if params[:tag_id].to_i > 0
          dish = dish.first
          rating = dish.rating
          
          if params[:type] != 'home_cooked' && params[:type] != 'delivery'
            fsq_checkins_count = dish.fsq_checkins_count if dish.fsq_checkins_count > 0
          end
          
        end        
      end
      
      if rating.nil?
        start = 1
        rating = 5
      else
        start = 0
      end
      dishes_array = []
      
      if rating && rating > 0
        step = 0.25  
        (0..(5-step)).step(step) do |n|
            n1 = 5 - n
            n2 = n1 - step != 0 ? n1 - step : 0
            if (rating > n2 && rating <= n1) || (rating > n2 && rating > n1 && dishes_array.count < limit)
            
              start = 1 if rating > n2 && rating > n1 && dishes_array.count < limit
              if dishes_between = dishes.where("rating > ? AND rating <= ?", n2, n1)
              
                dishes_between.each do |d|
                  if start == 1
                    if dishes_array.count < limit
                      network_data = Network.select([:id, :name]).find_by_id(d.network_id) if params[:type] != 'home_cooked' && params[:type] != 'delivery' 
                      dishes_array.push({
                        :id => d.id,
                        :name => d.name,
                        :rating => d.rating,
                        :votes => d.votes,
                        :image_sd => d.image_sd,
                        :image_hd => d.image_hd,
                        :network => params[:type] == 'home_cooked' ? {} : {
                          :id => params[:type] == 'delivery' ? d.delivery_id : network_data.id,
                          :name => params[:type] == 'delivery' ? d.delivery.name : network_data.name
                        }
                      })
                    else
                      break
                    end
                  end
                  start = 1 if dish && d.id == dish.id
                end
              end
            end
        end
      end
      
      if dishes_array.count < limit && params[:type] != 'home_cooked'
        if params[:type] == 'delivery'
          
          if dishes_between = dishes.where("rating = 0")
            dishes_between.each do |d|
              
              if dishes_array.count < limit
                dishes_array.push({
                  :id => d.id,
                  :name => d.name,
                  :rating => d.rating,
                  :votes => d.votes,
                  :image_sd => d.image_sd,
                  :image_hd => d.image_hd,
                  :network => {
                    :id => d.delivery_id,
                    :name => d.delivery.name
                  }
                })
              else
                break
              end
              
            end
          end
        else
          
          foursquare_max = Dish.select("max(fsq_checkins_count) as max_fsq").first.max_fsq
          fsq_checkins_count = foursquare_max if fsq_checkins_count.nil? || fsq_checkins_count == 0

          step_fsq = foursquare_max/2
          (0..(foursquare_max-step_fsq)).step(step_fsq) do |n|
        
            n1 = foursquare_max - n
            n2 = n1 - step_fsq != 0 ? n1 - step_fsq : 0
    
            if (fsq_checkins_count > n2 && fsq_checkins_count <= n1) || (fsq_checkins_count > n2 && fsq_checkins_count > n1 && dishes_array.count < limit)
      
              start = 1 if fsq_checkins_count > n2 && fsq_checkins_count > n1 && dishes_array.count < limit
              if dishes_between = dishes.where("fsq_checkins_count > ? AND fsq_checkins_count <= ? AND rating = 0", n2, n1)
        
                dishes_between.each do |d|
                  if start == 1
                    if dishes_array.count < limit
                      network_data = Network.select([:id, :name]).find_by_id(d.network_id) 
                      dishes_array.push({
                        :id => d.id,
                        :name => d.name,
                        :rating => d.rating,
                        :votes => d.votes,
                        :image_sd => d.image_sd,
                        :image_hd => d.image_hd,
                        :network => {
                          :id => network_data.id,
                          :name => network_data.name
                        }
                      })
                    else
                      break
                    end
                  end
                  start = 1 if dish && d.id == dish.id
                end
              end
            end
          end   
                   
        end
      end
      
      restaurants_array = []
      dishes_array.index_by {|r| r[:network][:id]}.values.each do |dish|
        Restaurant.select([:id, :name, :lat, :lon, :address, :network_id]).where(:network_id => dish[:network][:id]).by_distance(lat, lon).take(3).each do |r|
          restaurants_array.push({
            :id => r.id,
            :name => r.name,
            :lat => r.lat,
            :lon => r.lon,
            :address => r.address,
            :network_id => r.network_id,
          })
        end
      end      
    
    else
      $error = {:description => 'Parameters missing', :code => 8}    
    end
    
    return render :json => {
            :dishes => dishes_array,
            :restaurants => restaurants_array,
            :error => $error
    }
  end
  
  def get_restaurants
    
    limit = params[:limit] ||= 25
    offset = params[:offset] ||= 0
    
    filters = []
    if params[:bill] && params[:bill].length == 5 && params[:bill] != '00000' && params[:bill] != '11111'
      bill = []
      bill.push('bill = "до 500 руб"') if params[:bill][0] == '1'
      bill.push('bill = "500 - 1000 руб"') if params[:bill][1] == '1'
      bill.push('bill = "1000 - 2000 руб"') if params[:bill][2] == '1'
      bill.push('bill = "2000 - 5000 руб"') if params[:bill][3] == '1'
      bill.push('bill = "более 5000 руб"') if params[:bill][4] == '1'
      filters.push(bill.join(' OR ')) if bill.count > 0
    end
    
    etc = []
    etc.push('wifi != 0 OR wifi != "нет"') if params[:wifi] == '1'
    etc.push('terrace = 1') if params[:terrace] == '1'
    etc.push('cc = 1') if params[:accept_bank_cards] == '1'
    
    filters.push(etc.join(' AND ')) if etc.count > 0
    all_filters = filters.join(' AND ')
    
    if params[:open_now]
      wday = Date.today.strftime("%a").downcase
      now = Time.now.strftime("%H%M")
      open_now = "#{now} BETWEEN REPLACE(LEFT(#{wday},5), ':', '') AND REPLACE(RIGHT(#{wday},5), ':', '')"
      
      if now.to_i < 1000
        now24 = now.to_i + 2400
        open_now = open_now + " OR #{now24} BETWEEN REPLACE(LEFT(#{wday},5), ':', '') AND REPLACE(RIGHT(#{wday},5), ':', '')"
      end    
      all_filters = all_filters ? all_filters + open_now : open_now
    end      
    
    city_radius = 30

    city_lat = 55.753548
    city_lon = 37.609239
    pi = Math::PI
    
    load_additional = 1 if !params[:lat].blank? && params[:lon] && ((Math.acos(
    	Math.sin(city_lat * pi / 180) * Math.sin(params[:lat].to_f * pi / 180) + 
    	Math.cos(city_lat * pi / 180) * Math.cos(params[:lat].to_f * pi / 180) * 
    	Math.cos((params[:lon].to_f - city_lon) * pi / 180)) * 180 / pi) * 60 * 1.1515) * 1.609344 >= city_radius
    
    lat = !params[:lat].blank? ? params[:lat] : '55.753548'
    lon = !params[:lon].blank? ? params[:lon] : '37.609239'
    
    if params[:radius] == 'city'
      radius = 30
    else
      radius = params[:radius].to_f != 0 ? params[:radius].to_f : nil
    end
    
    
    if params[:type] == 'delivery'
      restaurants = Delivery.select('deliveries.id, deliveries.name, deliveries.address, deliveries.city, deliveries.lat, deliveries.lon, deliveries.rating, deliveries.votes').order("rating DESC, votes DESC")
    else
      if params[:sort] == 'distance'
        if radius
          restaurants = Restaurant.near(lat, lon, radius).by_distance(lat, lon)
        else
          restaurants = Restaurant.by_distance(lat, lon)
        end     
        restaurants = restaurants.joins('LEFT OUTER JOIN `networks` ON `networks`.`id` = `restaurants`.`network_id`').where('lat IS NOT NULL AND lon IS NOT NULL').order("restaurants.fsq_checkins_count DESC, networks.rating DESC, networks.votes DESC")
      else
        if radius
          restaurants = Restaurant.near(lat, lon, radius)
        else
          restaurants = Restaurant
        end
        restaurants = restaurants.joins("LEFT OUTER JOIN `networks` ON `networks`.`id` = `restaurants`.`network_id` JOIN (
        #{Restaurant.select('id, address').where('restaurants.lat IS NOT NULL AND restaurants.lon IS NOT NULL').order('restaurants.fsq_checkins_count DESC').to_sql}) r1
        ON `restaurants`.`id` = `r1`.`id`").where('restaurants.lat IS NOT NULL AND restaurants.lon IS NOT NULL').order("restaurants.fsq_checkins_count DESC, networks.rating DESC, networks.votes DESC").by_distance(lat, lon).group('restaurants.name')
      end
      
    end
    
    unless params[:search].blank?
      search = params[:search].gsub(/[']/) { |x| '\\' + x }
      restaurants = restaurants.where("restaurants.`name` LIKE ? OR restaurants.`name_eng` LIKE ?", "%#{search}%", "%#{search}%")
    end
    
    restaurants = restaurants.search_by_word(params[:keyword]) unless params[:keyword].blank?
    restaurants = restaurants.search_by_tag_id(params[:tag_id]) if params[:tag_id].to_i > 0
    restaurants = restaurants.where(all_filters) unless all_filters.blank?
    restaurants = restaurants.where("network_id IN (#{params[:network_id]})") unless params[:network_id].blank?
    
    if params[:type] != 'delivery'
      restaurants = restaurants.select('restaurants.id, restaurants.name, restaurants.address, restaurants.city, restaurants.lat, restaurants.lon, restaurants.rating, restaurants.votes, restaurants.network_id, restaurants.fsq_id')    
    end
    restaurants = restaurants.limit("#{offset}, #{limit}")
    
    networks = []
    num_images = 20    
    
    if params[:type] == 'delivery'
      
      restaurants.each do |r|
        dishes = []
      
        if params[:tag_id].to_i > 0
          dishes_w_img = r.dish_deliveries.select('DISTINCT dish_deliveries.id, dish_deliveries.name, dish_deliveries.photo, dish_deliveries.rating, dish_deliveries.votes, dish_deliveries.dish_type_id').order("(dish_deliveries.rating - 3)*dish_deliveries.votes DESC, dish_deliveries.photo DESC").includes(:reviews).where("dish_deliveries.photo IS NOT NULL OR (dish_deliveries.rating > 0 AND reviews.photo IS NOT NULL)").limit(num_images).search_by_tag_id(params[:tag_id])
        else
          dishes_w_img = r.dish_deliveries.select('DISTINCT dish_deliveries.id, dish_deliveries.name, dish_deliveries.photo, dish_deliveries.rating, dish_deliveries.votes, dish_deliveries.dish_type_id').order("(dish_deliveries.rating - 3)*dish_deliveries.votes DESC, dish_deliveries.photo DESC").includes(:reviews).where("dish_deliveries.photo IS NOT NULL OR (dish_deliveries.rating > 0 AND reviews.photo IS NOT NULL)").limit(num_images)
        end
      
        dishes_w_img.each do |dish|
            dishes.push({
              :id => dish.id,
              :name => dish.name,
              :photo => dish.image_sd,
              :rating => dish.rating,
              :votes => dish.votes
            })
        end
          
        networks.push({:network_id => r.id, :dishes => dishes})
      end
    else  
      
      restaurants.each do |r|
        dont_add = 0
        networks.each do |n|
          dont_add = 1 && break if r.network_id == n[:network_id]
        end
        if dont_add == 0
          dishes = []
        
          if params[:tag_id].to_i > 0
            dishes_w_img = r.network.dishes.select('DISTINCT dishes.id, dishes.name, dishes.photo, dishes.rating, dishes.votes, dishes.dish_type_id').order("(dishes.rating - 3)*dishes.votes DESC, dishes.photo DESC").includes(:reviews).where("dishes.photo IS NOT NULL OR (dishes.rating > 0 AND reviews.photo IS NOT NULL)").limit(num_images).search_by_tag_id(params[:tag_id])
          else
            dishes_w_img = r.network.dishes.select('DISTINCT dishes.id, dishes.name, dishes.photo, dishes.rating, dishes.votes, dishes.dish_type_id').order("(dishes.rating - 3)*dishes.votes DESC, dishes.photo DESC").includes(:reviews).where("dishes.photo IS NOT NULL OR (dishes.rating > 0 AND reviews.photo IS NOT NULL)").limit(num_images)
          end
        
          dishes_w_img.each do |dish|
              dishes.push({
                :id => dish.id,
                :name => dish.name,
                :photo => dish.image_sd,
                :rating => dish.rating,
                :votes => dish.votes
              })
          end
          networks.push({:network_id => r.network_id, :dishes => dishes}) 
        end
      end
      
    end

    return render :json => {
          :load_additional => load_additional ||= 0,
          :restaurants => restaurants.as_json({:keyword => params[:keyword] ||= nil}),
          :networks => networks,
          :error => $error
    }
    
  end
  
  def upload_photo
    if params[:uuid] && params[:photo]     
      $error = {:description => 'Fails to load image', :code => 9} unless Image.create({:photo => params[:photo], :uuid => params[:uuid]})           
    else
      $error = {:description => 'Parameters missing', :code => 8}
    end
    
    return render :json => {
      :error => $error
    }
  end
  
  def get_review  
    
    if params[:review_id]
      if params[:self_review].to_i == 1
        review = Dish.find_by_id(params[:review_id]).self_review
      else
        review = Review.find_by_id(params[:review_id])
      end
    else
      $error = {:description => 'Parameters missing', :code => 8}
    end
    
    review = review.format_review_for_api if review && params[:info].to_i == 1
    
    return render :json => {
      :review => review,
      :error => $error
    }
  end
  
  def get_user_stats
    if user = User.find_by_id(params[:user_id])
      
      following_count = Follower.select(:id).where(:user_id => user.id).count(:id) rescue 0 
      followers_count = Follower.select(:id).where(:follow_user_id => user.id).count(:id) rescue 0
            
      if likes_a = Review.select([:id, :photo]).where('id IN (SELECT review_id FROM likes WHERE user_id = ?)', user.id)
        count = likes_a.count
        likes = {:data => [], :count => 0}
        
        likes_a.each do |l|
          likes[:data].push({
            :id => l.id,
            :photo => l.photo.iphone.url
          })
        end
        likes[:count] = count
      end
      
      if reviews_a = Review.select([:id, :photo]).where('user_id = ?', user.id)
        count = reviews_a.count
        reviews = {:data => [], :count => 0}
        
        reviews_a.each do |r|
          reviews[:data].push({
            :id => r.id,
            :photo => r.photo.iphone.url
          })
        end
        reviews[:count] = count
      end
      
      top_in_restaurants = {:data => [], :count => 0}
      count = 0
      if restaurants = Restaurant.select([:id, :photo, :network_id]).where(:top_user_id => user.id)
        count += restaurants.count
        
        restaurants.each do |d|
          top_in_restaurants[:data].push({
            :id => d.id,
            :photo => d.thumb,
            :type => nil
          })
        end
        reviews[:count] = count
      end
      
      if restaurants = Delivery.select([:id, :photo, :id]).where(:top_user_id => user.id)
        count += restaurants.count
        
        restaurants.each do |d|
          top_in_restaurants[:data].push({
            :id => d.id,
            :photo => d.thumb,
            :type => 'delivery'
          })
        end
        reviews[:count] = count
      end
      
      top_in_dishes = {:data => [], :count => 0}
      count = 0
      if dishes = Dish.select([:id, :photo]).where(:top_user_id => user.id)
        count += dishes.count
        
        dishes.each do |d|
          top_in_dishes[:data].push({
            :id => d.id,
            :photo => d.image_sd,
            :type => nil
          })
        end
        reviews[:count] = count
      end
      
      if dishes = DishDelivery.select([:id, :photo]).where(:top_user_id => user.id)
        count += dishes.count
        
        dishes.each do |d|
          top_in_dishes[:data].push({
            :id => d.id,
            :photo => d.image_sd,
            :type => 'delivery'
          })
        end
        reviews[:count] = count
      end
      
      if dishes = HomeCook.select([:id, :photo]).where(:top_user_id => user.id)
        count += dishes.count
        
        dishes.each do |d|
          top_in_dishes[:data].push({
            :id => d.id,
            :photo => d.image_sd,
            :type => 'home_cooked'
          })
        end
        reviews[:count] = count
      end
      
    else
      $error = {:description => 'Parameters missing', :code => 941}
    end
    return render :json => {
          :likes => likes,
          :dish_ins => reviews,
          :top_in_dishes => top_in_dishes,
          :top_in_restaurants => top_in_restaurants,
          :following_count => following_count,
          :followers_count => followers_count,
          :error => $error
    }
      
  end
  
  def get_user_profile
    if params[:id]
      
      limit = params[:limit] ? params[:limit] : 25
      offset = params[:offset] ? params[:offset] : 0
      
      following_count = Follower.select(:id).where(:user_id => params[:id]).count(:id) rescue 0 
      followers_count = Follower.select(:id).where(:follow_user_id => params[:id]).count(:id) rescue 0
      
      params[:type] ||= 'reviews'
      
      reviews = Review.where('id IN (SELECT review_id FROM likes WHERE user_id = ?)',params[:id]) if params[:type] == 'likes'
      reviews = Review.where('user_id = ?',params[:id]) if params[:type] == 'reviews'
        
      if reviews
        review_count = reviews.count
        reviews = reviews.limit("#{offset}, #{limit}").order("id DESC")
      
        review_data = Array.new
        reviews.each do |review|
          review_data.push(review.format_review_for_api(params[:id]))
        end
        
        return render :json => {
              :review_count => review_count,
              :reviews => review_data, 
              :following_count => following_count,
              :followers_count => followers_count,              
              :error => $error
        }
      end
      
      if params[:type] == 'notifications'
        if Session.check_token(params[:id], params[:token])
          
          limit = 100
          data = []
          
          APN::Notification.where("user_id_to = ?", params[:id]).limit(limit).order("id DESC").each do |n|
            user = User.find_by_id(n.user_id_from)
            data.push({
              :date => n.created_at.to_i,
              :type => n.notification_type,
              :review_id => n.review_id,
              :read => n.read,
              :text => n.alert,
              :user => {
                :name => user.name,
                :id => user.id,
                :photo => user.user_photo
              }
            })
            n.read = 1
            n.save
          end 
          
          # data = data.sort_by { |k| k[:data] }.reverse!
          
        else
          $error = {:description => 'Parameters missing', :code => 822}
        end
        
        return render :json => {
              :notifications => data,
              :error => $error
        }
        
        end   
    else
      $error = {:description => 'Parameters missing', :code => 832}
      return render :json => {
            :following_count => following_count,
            :followers_count => followers_count,
            :error => $error
      }
    end
  end
  
  def get_reviews
    
    limit = params[:limit] ? params[:limit] : 25
    
    if params[:following_for_user_id].to_i > 0
      reviews = Review.following(params[:following_for_user_id].to_i)
    else
      reviews = Review.where('photo IS NOT NULL')
    end
    
    reviews = reviews.limit(limit).order('id DESC').includes(:dish)
    reviews = reviews.where("id < ?", params[:review_id]) if params[:review_id] 
    
    review_data = []
    reviews.each {|r| review_data.push(r.format_review_for_api(params[:user_id]))}    
    
    return render :json => {
      :reviews => review_data,
      :error => $error
    }
          
  end
  
  def like_review
    
    if params[:review_id] && Session.check_token(params[:user_id], params[:token])
      data = Like.save(params[:user_id], params[:review_id], params[:self_review])
    else
      $error = {:description => 'Parameters missing', :code => 8}
    end
    
    return render :json => {
      :error => $error
    }
  end
  
  def comment_on_review
    if params[:comment] && params[:review_id] && Session.check_token(params[:user_id], params[:token])
      Comment.add({:user_id => params[:user_id], :review_id => params[:review_id], :text => params[:comment]}, params[:self_review])
    else
      return render :json => {
        :error => {:description => 'Parameters missing', :code => 8}
      }
    end
    return render :json => {
      :error => $error
    }
  end
  
  def get_restaurant_menu
    if params[:restaurant_id]
      
      if params[:type] == 'delivery'
        if restaurant = Delivery.find_by_id(params[:restaurant_id])
          dishes = DishDelivery.where('delivery_id = ?', restaurant.id)
        else
          $error = {:description => 'Restaurant not found', :code => 357}
        end
      else
        if restaurant = Restaurant.find_by_id(params[:restaurant_id])
          dishes = Dish.where('network_id = ?', restaurant.network_id)
        else
          $error = {:description => 'Restaurant not found', :code => 357}
        end
      end
      
      if dishes.count > 0
      
        categories = []
        types = []
      
        dishes.group(:dish_category_id).each do |dish|
          sort = DishCategoryOrder.find_by_restaurant_id_and_dish_category_id(restaurant.id, dish.dish_category_id)
          categories.push({
            :id => dish.dish_category_id, 
            :name => dish.dish_category.name_eng.nil? ? dish.dish_category.name : dish.dish_category.name_eng, 
            :order => sort ? sort.order : 9999
          })
        end
        categories.sort_by!{|k| k[:order] && k.delete(:order) }
      
        dishes.group(:dish_type_id).each do |dish|
          types.push({:id => dish.dish_type.id, :name => dish.dish_type.name_eng, :order => dish.dish_type.order}) if dish.dish_type
        end

        types.sort_by!{|k| k[:order] }        
        
        if params[:type] == 'delivery'  
          dish_delivery = []
          dishes.each do |d|
            dish_delivery.push({
              :dish => { 
                :id => d.id, 
                :name => d.name, 
                :dish_category_id => d.dish_category_id, 
                :dish_type_id => d.dish_type_id, 
                :description => d.description, 
                :rating => d.rating, 
                :votes => d.votes,
                :image_sd => d.image_sd, 
                :image_hd => d.image_hd, 
                :price => d.price
            }})
          end
          dishes = dish_delivery.as_json
        else
          dishes = dishes.as_json(:only => [:id, :name, :dish_category_id, :dish_type_id, :description, :rating, :votes], :methods => [:image_sd, :image_hd, :price])          
        end
      
        return render :json => {
          :dishes => dishes, 
          :categories => categories.as_json(),
          :types => types.as_json,
          :error => $error
        }
      else
        
      end
    end
    return render :json => {
      :error => $error
    }
  end
  
  def add_review
    
    if params[:review] && Session.check_token(params[:review][:user_id], params[:token]) && params[:review][:rating].to_f > 0 && params[:review][:rating].to_f <= 5
      
      params[:review][:photo] = Image.review_photo(params[:uuid]) if params[:uuid]
      params[:review][:friends] = User.put_friends(params[:fb_friends], params[:tw_friends]) if params[:fb_friends] || params[:tw_friends]
      
      if params[:review][:rtype] == 'home_cooked'
          
              if params[:dish] && params[:dish][:name] && params[:dish][:dish_type_id]   
                unless dish = HomeCook.find_by_name(params[:dish][:name])
            
                  unless dish = HomeCook.create(params[:dish])
                    return render :json => {:error => {:description => 'Dish create error', :code => 6}}
                  end

                end
                params[:review][:dish_id] = dish.id
              else
                return render :json => {:error => {:description => 'Home Cooked is Missing', :code => 1015}}
              end
        
            r = Review.save_review(params[:review])
            
      elsif params[:review][:rtype] == 'delivery'
              
              if r = Delivery.find_by_id(params[:review][:restaurant_id])
                params[:review][:restaurant_id] = r.id
              elsif r = Delivery.add_from_4sq_with_menu(params[:foursquare_venue_id])        
                params[:review][:restaurant_id] = r.id
              else
                return render :json => {:error => {:description => 'Restaurant not found', :code => 1}}
              end
        
              unless dish = DishDelivery.find_by_id(params[:review][:dish_id])
                if params[:dish] && params[:dish][:name]
                  params[:dish][:delivery_id] = r.id  

                  unless dish = DishDelivery.create(params[:dish])
                    return render :json => {:error => {:description => 'Dish create error', :code => 6}}
                  end

                else
                  return render :json => {:error => {:description => 'DishDelivery find error', :code => 6}}
                end
              end
        
              params[:review][:dish_id] = dish.id
              r = Review.save_review(params[:review])
      
      else
              if r = Restaurant.find_by_id(params[:review][:restaurant_id])
                params[:review][:network_id] = r.network_id
              elsif r = Restaurant.add_from_4sq_with_menu(params[:foursquare_venue_id])        
                params[:review][:restaurant_id] = r.id
                params[:review][:network_id] = r.network_id
              else
                return render :json => {:error => {:description => 'Restaurant not found', :code => 1}}
              end
        
              unless dish = Dish.find_by_id(params[:review][:dish_id])
                if params[:dish] && params[:dish][:name]  

                  params[:dish][:network_id] = r.network_id
                  params[:dish][:created_by_user] = params[:review][:user_id]

                  unless dish = Dish.create(params[:dish])
                    return render :json => {:error => {:description => 'Dish create error', :code => 6}}
                  end
            
                else
                  return render :json => {:error => {:description => 'Dish find error', :code => 6}}
                end
              end
        
              params[:review][:dish_id] = dish.id
              r = Review.save_review(params[:review])
      end  
       
       
      unless r.blank?
        
        if r.rtype == 'home_cooked'
          dish_name = r.home_cook.name
          restaurant_name = nil
        elsif r.rtype == 'delivery'
          dish_name = r.dish_delivery.name
          restaurant_name = r.delivery.name 
        else
          dish_name = r.dish.name
          restaurant_name = r.restaurant.name
        end
                   
        Notification.send(r.user_id, 'dishin', nil, dish_name, nil, nil, r.id)        

        unless r.friends.blank?
          Notification.send(r.user_id, 'tagged', nil, nil, restaurant_name, r.friends)
          Notification.send(r.user_id, 'tagged_by_friend', nil, nil, restaurant_name, r.friends, r.id)
        end

        unless r.photo.iphone_retina.url.blank?
          if params[:post_on_facebook] == '1'
            system "rake facebook:dishin REVIEW_ID='#{r.id}' &"
          end
        end  
      end
            
    else
      $error = {:description => 'Parameters missing', :code => 8}  
    end
    
    return render :json => {
      :error => $error
    }
  
  end
  
  
  def add_review_old
    # TODO: On Dish and Restaurant adding create DishTags and RestaurantTags
    
    if params[:review] && params[:review][:rating] && Session.check_token(params[:review][:user_id], params[:token])
      # params[:review][:user_id] = params[:user_id]
      
      # chk24 = Review.where("user_id = ? AND dish_id = ? AND created_at >= current_date()-1",params[:review][:user_id], params[:review][:dish_id])
      # return render :json => {:error => {:description => 'You can post review only once at 24 hours', :code => 357}} unless chk24.blank?
      
      if params[:fb_friends] || params[:tw_friends]
        params[:review][:friends] = User.put_friends(params[:fb_friends], params[:tw_friends])
      end
      
      if params[:home_cooked].to_i == 1 || params[:review][:rtype] == 'home_cooked'
        
        if (params[:dish] && (params[:dish][:name] && params[:dish][:dish_type_id])) || params[:review][:dish_id]
          
          if params[:review][:dish_id].to_i > 0
            unless dish = HomeCook.find_by_id(params[:review][:dish_id]) 
              return render :json => {:error => {:description => 'Dish not found', :code => 1000}}
            end
          elsif params[:dish][:name] && params[:dish][:dish_type_id]
            unless dish = HomeCook.find_by_name(params[:dish][:name])
              data = {
                :name => params[:dish][:name], 
                :dish_type_id => params[:dish][:dish_type_id],
                :dish_subtype_id => params[:dish][:dish_subtype_id]
              }
              dish = HomeCook.create(data)
            end
          else
            return render :json => {:error => {:description => 'Params missing', :code => 1012}}
          end
          
        else
          return render :json => {:error => {:description => 'Params missing', :code => 1016}}
        end
        
        params[:review][:dish_id] = dish.id
        params[:review][:home_cooked] = 1 
        
        if params[:uuid] && image = Image.find_by_uuid(params[:uuid])
          params[:review][:photo] = File.open(image.photo.file.file)  
          image.destroy
        end 
        
        if params[:review][:user_id]
          r = Review.save_review(params[:review])
        else
          return render :json => {:error => {:description => 'User not found', :code => 8}}
        end
      elsif params[:review][:rtype] == 'delivery'       
        
      else  

        if params[:review][:restaurant_id].blank?
          
          dish_category_id = ''
          if !params[:foursquare_venue_id].blank?
            client = Foursquare2::Client.new(:client_id => 'AJSJN50PXKBBTY0JZ0Q1RUWMMMDB0DFCLGMN11LBX4TVGAPV', :client_secret => '5G13AELMDZPY22QO5QSDPNKL05VT1SUOV5WJNGMDNWGCAESX')
            venue = client.venue(params[:foursquare_venue_id])

            if r = Restaurant.find_by_fsq_id(params[:foursquare_venue_id])
              params[:review][:restaurant_id] = r.id
              params[:review][:network_id] = r.network_id
            else
            
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
                :name => venue.name,
                :phone => venue.contact.formattedPhone,
                :restaurant_categories => category_id.join(','),
                :network_id => network_id
              }
              
              if r = Restaurant.create(data)
                params[:review][:restaurant_id] = r.id
                params[:review][:network_id] = r.network_id
              
                client.venue_menu(params[:foursquare_venue_id]).each do |m|
                  cat_ord = 0
                  m.entries.fourth.second.items.each do |i|
                   
                    if dish_category = DishCategory.find_by_name(i.name)
                      dish_category_id = dish_category.id
                    else
                      dish_category_id = DishCategory.create({:name => i.name}).id
                    end
                  
                    cat_ord += 1
                    DishCategoryOrder.create({
                      :restaurant_id => params[:review][:restaurant_id], 
                      :network_id =>  params[:review][:network_id],
                      :dish_category_id => dish_category_id,
                      :order => cat_ord
                    })
                  
                    i.entries.third.second.items.each do |d|  
                    
                      if d.prices 
                        price = /(.)(\d+\.\d+)/.match(d.prices.first)[2]
                        currency = /(.)(\d+\.\d+)/.match(d.prices.first)[1]
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
              
                system "rake tags:match_dishes NETWORK_ID='#{params[:review][:network_id]}' &"
                system "rake tags:match_rest NETWORK_ID='#{params[:review][:network_id]}' &"
              
              else
                return render :json => {:error => {:description => 'Error on creat restaurant', :code => 1}}
              end
            end
          else
            return render :json => {:error => {:description => 'Restaurant not found', :code => 1}}
          end
        else
          if r = Restaurant.find_by_id(params[:review][:restaurant_id])
            params[:review][:network_id] = r.network_id
          else
            return render :json => {:error => {:description => 'Restaurant not found', :code => 1}} 
          end
        end
      
        return render :json => {:error => {:description => "Rating '#{params[:review][:rating]}' is not in range", :code => 2}} if params[:review][:rating].to_i > 5 || params[:review][:rating].to_i < 0

        if params[:uuid] && image = Image.find_by_uuid(params[:uuid])
          params[:review][:photo] = File.open(image.photo.file.file)  
          image.destroy
        end
    
        if !params[:review][:dish_id] && params[:dish][:name] # && params[:dish][:dish_type_id]
          if dish = Dish.find_by_network_id_and_name(params[:review][:network_id], params[:dish][:name])
            params[:review][:dish_id] = dish.id
          else
            params[:dish][:network_id] = params[:review][:network_id]
            # return render :json => {:error => {:description => 'Dish type not found', :code => 4}} unless DishType.find_by_id(params[:dish][:dish_type_id])
            # return render :json => {:error => {:description => 'Dish subtype not found', :code => 5}} if params[:dish][:dish_subtype_id] && !DishSubtype.find_by_id(params[:dish][:dish_subtype_id])
        
            if !params[:dish][:dish_type_id].blank? && DishType.find_by_id(params[:dish][:dish_type_id])
              dish_category = DishType.find_by_id(params[:dish][:dish_type_id]).name
              params[:dish][:dish_category_id] = DishCategory.find_by_name(dish_category) ? DishCategory.find_by_name(dish_category).id : DishCategory.create(:name => dish_category).id
            else
              params[:dish][:dish_category_id] = dish_category_id
            end
          
            return render :json => {:error => {:description => 'Dish category not found', :code => 4}} unless params[:dish][:dish_category_id]
          
            params[:dish][:created_by_user] = params[:review][:user_id]
        
            if dish_new = Dish.create(params[:dish])
              dish_new.match_tags
              params[:review][:dish_id] = dish_new.id
            else
              return render :json => {:error => {:description => 'Dish create error', :code => 6}}        
            end
          end
        end
      
        return render :json => {:error => {:description => 'Dish not found', :code => 7}} unless dfc = Dish.find_by_id(params[:review][:dish_id])
      
        if params[:review][:user_id]
          r = Review.save_review(params[:review])
        else
          return render :json => {:error => {:description => 'User not found', :code => 69}}
        end
        
      end
      
      unless r.blank?
        
        # dish_name = r.home_cooked == true ? r.home_cook.name : r.dish.name
        
        if r.home_cooked == true
          dish_name = r.home_cook.name
        else
          dish_name = r.dish.name
        end
        
        Notification.send(r.user_id, 'dishin', nil, dish_name, nil, nil, r.id)        

        unless r.friends.blank?
          Notification.send(r.user_id, 'tagged', nil, nil, r.restaurant ? r.restaurant.name : nil, r.friends)
          Notification.send(r.user_id, 'tagged_by_friend', nil, nil, r.restaurant ? r.restaurant.name : nil, r.friends, r.id)
        end

        unless r.photo.iphone_retina.url.blank?
          if params[:post_on_facebook] == '1'
            system "rake facebook:dishin REVIEW_ID='#{r.id}' &"
          end
        end
        
      end
      
      # Invite user
      # graph.put_wall_post("Hey, Welcome to the Web Application!!!!", {:name => "..."}, "682620569")
      
    else
      $error = {:description => 'Parameters missing', :code => 1224}
    end
    return render :json => {
      :error => $error
    } 
  end
  
end