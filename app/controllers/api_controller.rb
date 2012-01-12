class ApiController < ApplicationController
  
  before_filter :init_error
  
  def init_error
    $error = {:description => nil, :code => nil}
  end
  
  def del_comment
    if params[:comment_id] && params[:access_token]
      user_id = User.get_user_by_fb_token(params[:access_token])     
      if comment = Comment.find_by_id_and_user_id(params[:comment_id], user_id)
        comment.delete
      else
        $error = {:description => 'Comment not found', :code => 357}
      end
    else
        $error = {:description => 'Params missing', :code => 357}
    end
    return render :json => {
          :error => $error
    }
  end
  
  def del_review
    if params[:review_id] && params[:access_token]      
        user_id = User.get_user_by_fb_token(params[:access_token]) 
        if review = Review.find_by_id_and_user_id(params[:review_id], user_id)
          review.delete
        else
          $error = {:description => 'Review not found', :code => 357}  
        end
    else
        $error = {:description => 'Params missing', :code => 357}
    end
    return render :json => {
          :error => $error
    }
  end
  
  def get_user_id
    if params[:id] && params[:provider]
      user = User.find_by_facebook_id(params[:id]) if params[:provider] == 'facebook'
      user_id = user.id if user
    end
    return render :json => {
          :user_id => user_id, 
          :error => $error
    }
  end
  
  def get_dish
    if params[:dish_id]
      user_id = User.find_by_id(User.get_user_by_fb_token(params[:access_token])).id if params[:access_token]      
      return render :json => API.get_dish(user_id,params[:dish_id])
    else
      return render :json => {:error => $error}
    end
  end
  
  def get_common_data
    return render :json => {
          :types => DishType.where('id != 10').order('`order`'),
          :tags => Tag.get_all,
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
      return render :json => API.api_get_restaurant(id, type)
    else
      return render :json => {:error => $error}
    end
  end
  
  def get_dishes
    limit = params[:limit] ||= 25
    offset = params[:offset] ||= 0
    
    lat = params[:lat] ||= '55.753548'
    lon = params[:lon] ||= '37.609239'
    
    radius = params[:radius].to_f != 0 ? params[:radius].to_f: nil
    search = params[:search].blank? ? params[:keyword] : params[:search]
    
    if radius
      networks = []
      Restaurant.near(params[:lat], params[:lon], radius).each do |restaurant|
       networks.push(restaurant.network.id) if networks.index(restaurant.network.id).blank?
      end
      dishes = Dish.where("dishes.network_id IN (#{networks.join(',')})") if networks.count > 0
    end
    
    filters = []
    if params[:bill] && params[:bill].length == 5 && params[:bill] != '00000'
      bill = []
      bill.push('bill = "до 500 руб"') if params[:bill][0] == '1'
      bill.push('bill = "500 - 1000 руб"') if params[:bill][1] == '1'
      bill.push('bill = "1000 - 2000 руб"') if params[:bill][2] == '1'
      bill.push('bill = "2000 - 5000 руб"') if params[:bill][3] == '1'
      bill.push('bill = "более 5000 руб"') if params[:bill][4] == '1'
      filters.push(bill.join(' OR ')) if bill.count > 0
    end
    
    dishes ||= Dish
    dishes = dishes.custom_search(search) unless search.blank?
    dishes = dishes.where('dish_type_id = ?', params[:type]) unless params[:type].blank?
    dishes = dishes.where(filters) unless filters.blank?
    dishes = dishes.select('`dishes`.`id`, `dishes`.`name`, `dishes`.`photo`, `dishes`.`rating`, `dishes`.`votes`, `dishes`.`network_id`, `networks`.`id`, `networks`.`name` AS t1_r1').joins('LEFT OUTER JOIN `networks` ON `networks`.`id` = `dishes`.`network_id`')
    if params[:sort] == 'distance'
      dishes = dishes.by_distance(params[:lat], params[:lon]).order('dishes.rating DESC, dishes.votes DESC, networks.rating DESC, networks.votes DESC, dishes.photo DESC, fsq_checkins_count DESC')  
    else
      dishes = dishes.order('dishes.rating DESC, dishes.votes DESC, networks.rating DESC, networks.votes DESC, dishes.photo DESC, fsq_checkins_count DESC').by_distance(params[:lat], params[:lon])  
    end
    
    count = dishes.count('dishes.id')
    dishes = dishes.limit("#{offset}, #{limit}")
    
    restaurants = []
    dishes.each do |dish|
      if radius
        dish.network.restaurants.select([:id, :name, :lat, :lon, :address]).near(params[:lat], params[:lon], radius).take(3).each do |r|
          restaurants.push({
            :id => r.id,
            :name => r.name,
            :lat => r.lat,
            :lon => r.lon,
            :address => r.address,
            :dish_id => dish.id,
          })
        end
      else
        dish.network.restaurants.select([:id, :name, :lat, :lon, :address]).where('lat IS NOT NULL AND lon IS NOT NULL').by_distance(params[:lat], params[:lon]).take(3).each do |r|
          restaurants.push({
            :id => r.id,
            :name => r.name,
            :lat => r.lat,
            :lon => r.lon,
            :address => r.address,
            :dish_id => dish.id,
          })
        end
      end
    end
         
    return render :json => {
            :dishes => dishes.as_json(:only => [:id, :name, :rating, :votes],
                  :methods => [:image_sd, :image_hd], 
                  :include => {
                    :network => {:only => [:id, :name]}
                  }),
            :restaurants => restaurants,
            :count => count,
            :error => $error
    }
  end
  
  def get_restaurants
    
    limit = params[:limit] ||= 25
    offset = params[:offset] ||= 0
    
    filters = []
    if params[:bill] && params[:bill].length == 5 && params[:bill] != '00000'
      bill = []
      bill.push('bill = "до 500 руб"') if params[:bill][0] == '1'
      bill.push('bill = "500 - 1000 руб"') if params[:bill][1] == '1'
      bill.push('bill = "1000 - 2000 руб"') if params[:bill][2] == '1'
      bill.push('bill = "2000 - 5000 руб"') if params[:bill][3] == '1'
      bill.push('bill = "более 5000 руб"') if params[:bill][4] == '1'
      filters.push(bill.join(' OR ')) if bill.count > 0
    end
    
    etc = []
    etc.insert(0,'wifi = 1') if params[:wifi] == '1'
    etc.push(0,'terrace = 1') if params[:terrace] == '1'
    etc.push(0,'cc = 1') if params[:accept_bank_cards] == '1'
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
      all_filters = all_filters ? all_filters + ' AND ' + open_now : open_now
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
    
    # return render :json => lon

            
    if params[:sort] == 'distance'
      if radius
        restaurants = Restaurant.near(lat, lon, radius).by_distance(lat, lon)
      else
        restaurants = Restaurant.by_distance(lat, lon)
      end     
      restaurants = restaurants.joins('LEFT OUTER JOIN `networks` ON `networks`.`id` = `restaurants`.`network_id`').where('lat IS NOT NULL AND lon IS NOT NULL').order("fsq_checkins_count DESC, networks.rating DESC, networks.votes DESC")
    else
      if radius
        restaurants = Restaurant.near(lat, lon, radius)
      else
        restaurants = Restaurant
      end
      restaurants = restaurants.joins("LEFT OUTER JOIN `networks` ON `networks`.`id` = `restaurants`.`network_id` JOIN (
      #{Restaurant.select('id, address').where('restaurants.lat IS NOT NULL AND restaurants.lon IS NOT NULL').by_distance(lat, lon).to_sql}) r1
      ON `restaurants`.`id` = `r1`.`id`").where('restaurants.lat IS NOT NULL AND restaurants.lon IS NOT NULL').order("fsq_checkins_count DESC, networks.rating DESC, networks.votes DESC").by_distance(lat, lon).group('restaurants.name')
    end
    
    restaurants = restaurants.where("restaurants.`name` LIKE ?", "%#{params[:search].gsub(/[']/) { |x| '\\' + x }}%") unless params[:search].blank?
    restaurants = restaurants.search_by_word(params[:keyword]) unless params[:keyword].blank?
    restaurants = restaurants.where(all_filters) unless all_filters.blank?
    
    if restaurants
      count = params[:sort] != 'distance' ? restaurants.count.count : restaurants.count
      restaurants = restaurants.select('restaurants.id, restaurants.name, restaurants.address, restaurants.lat, restaurants.lon, restaurants.network_id, restaurants.rating, restaurants.votes, restaurants.fsq_id').limit("#{offset}, #{limit}") 
    end
    
    num_images =20
    networks = []
    restaurants.each do |r|
      dont_add = 0
      networks.each do |n|
        dont_add = 1 && break if r.network_id == n[:network_id]
      end
      if dont_add == 0
        dishes = []
        if r.network.dishes
          unless params[:keyword].blank?
            r.network.dishes.select([:id, :photo]).custom_search(params[:keyword]).order("dishes.rating DESC, dishes.votes DESC, dishes.photo DESC").take(num_images).each {|d| dishes.push({:id => d[:id], :photo => d.image_sd}) unless d.image_sd.blank?}
          else
            r.network.dishes.order("dishes.rating DESC, dishes.votes DESC, dishes.photo DESC").take(num_images).each {|d| dishes.push({:id => d[:id], :photo => d.image_sd}) unless d.image_sd.blank?} 
          end
        end
        networks.push({:network_id => r.network_id, :dishes => dishes}) 
      end
    end

    return render :json => {
          :load_additional => load_additional ||= 0,
          :restaurants => restaurants.as_json({:keyword => params[:keyword] ||= nil}),
          :networks => networks,
          :count => count,
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
    
    review = Review.find_by_id(params[:review_id]).as_json if params[:review_id]
    return render :json => {
      :review => review,
      :error => $error
    }
  end
  
  def get_user_reviews
    if params[:id]
      
      limit = params[:limit] ? params[:limit] : 25
      offset = params[:offset] ? params[:offset] : 0
      
      if params[:likes].to_i == 1
        reviews = Review.where('id IN (SELECT review_id FROM likes WHERE user_id = ?)',params[:id])
      else
        reviews = Review.where('user_id = ?',params[:id])
      end
      
      review_count = reviews.count
      reviews = reviews.limit("#{offset}, #{limit}").order("id DESC")
      
      review_data = Array.new
      reviews.each do |review|
        review_data.push(review.format_review_for_api(params[:id]))
      end
      
    end
    
    return render :json => {
          :review_count => review_count,
          :reviews => review_data, 
          :error => $error
    }
  end
  
  def get_reviews
  
    limit = params[:limit] ? params[:limit] : 25
    offset = params[:offset] ? params[:offset] : 0
    reviews = Review.limit("#{offset}, #{limit}").order('id DESC').includes(:dish).where('photo IS NOT NULL')
    user_id = User.get_user_by_fb_token(params[:access_token]) if params[:access_token]
    count = Review.where('photo IS NOT NULL').count(:id)
    review_data = []
    reviews.each {|r| review_data.push(r.format_review_for_api(user_id))}    
    
    return render :json => {
      :reviews => review_data,
      :error => $error
    }
          
  end
  
  def like_review
    if params[:review_id] && params[:access_token]
      user_id = User.get_user_by_fb_token(params[:access_token])   
      data = Like.new.save_me(user_id, params[:review_id]) if user_id
      code = data[:error] ? 11 : nil
    else
      data[:error] = 'Parameters missing'
      code = 357
    end
    return render :json => {
      :error => {:description => data[:error], :code => code}
    }
  end
  
  def comment_on_review
    if params[:comment] && params[:review_id] && !params[:access_token].blank?
      user_id = User.get_user_by_fb_token(params[:access_token])
      unless user_id.blank?
        comment = Comment.new.add({:user_id => user_id, :review_id => params[:review_id], :text => params[:comment]})
      else
        $error = {:description => 'User not found', :code => 555}
      end
    else
      return render :json => {
        :error => {:description => 'Parameters missing', :code => 357}
      }
    end
    return render :json => {
      :error => $error
    }
  end
  
  def get_restaurant_menu
    if params[:restaurant_id]
      
      if restaurant = Restaurant.find_by_id(params[:restaurant_id])
      
        network_id = restaurant.network.id
        dishes = Dish.where('network_id = ?', network_id)
      
        categories = []
        types = []
      
        dishes.group(:dish_category_id).each do |dish|
          sort = DishCategoryOrder.find_by_restaurant_id_and_dish_category_id(restaurant.id, dish.dish_category.id)
          categories.push({
            :id => dish.dish_category.id, 
            :name => dish.dish_category.name, 
            :order => sort ? sort.order : 9999
          })
        end
        categories.sort_by!{|k| k[:order] && k.delete(:order) }
      
        dishes.group(:dish_type_id).each do |dish|
          types.push({:id => dish.dish_type.id, :name => dish.dish_type.name, :order => dish.dish_type.order}) if dish.dish_type
        end
        types.sort_by!{|k| k[:order] }
      
        return render :json => {
          :dishes => dishes.as_json(:only => [:id, :name, :dish_category_id, :dish_type_id, :description, :rating, :votes, :price], :methods => [:image_sd, :image_hd]), 
          :categories => categories.as_json(),
          :types => types.as_json,
          :error => $error
        }
      else
        $error = {:description => 'Restaurant not found', :code => 357}
      end
    else
      $error = {:description => 'Parameters missing', :code => 8}  
    end
    return render :json => {
      :error => $error
    }
  end
  
  def add_review
    if params[:review] && params[:review][:rating] && params[:access_token]
      params[:review][:user_id] = User.get_user_by_fb_token(params[:access_token])
      
      chk24 = Review.where("user_id = ? AND dish_id = ? AND created_at >= current_date()-1",params[:review][:user_id], params[:review][:dish_id])
      return render :json => {:error => {:description => 'You can post review only once at 24 hours', :code => 357}} unless chk24.blank?
      
      if params[:review][:restaurant_id].blank?
        
        unless params[:foursquare_venue_id].blank?
          client = Foursquare2::Client.new(:client_id => 'AJSJN50PXKBBTY0JZ0Q1RUWMMMDB0DFCLGMN11LBX4TVGAPV', :client_secret => '5G13AELMDZPY22QO5QSDPNKL05VT1SUOV5WJNGMDNWGCAESX')
          venue = client.venue(params[:foursquare_venue_id])

          if r = Restaurant.find_by_fsq_id(params[:foursquare_venue_id])
            params[:review][:restaurant_id] = r.id
            params[:review][:network_id] = r.network_id
          else

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
              :network_id => Network.find_by_name(venue.name) ? Network.find_by_name(venue.name).id : Network.create(:name => venue.name).id
            }
            if r = Restaurant.create(data)
              params[:review][:restaurant_id] = r.id
              params[:review][:network_id] = r.network_id
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
    
      if !params[:review][:dish_id] && params[:dish][:name] && params[:dish][:dish_type_id]
        params[:dish][:network_id] = params[:review][:network_id]
        return render :json => {:error => {:description => 'Dish type not found', :code => 4}} unless DishType.find_by_id(params[:dish][:dish_type_id])
        return render :json => {:error => {:description => 'Dish subtype not found', :code => 5}} if params[:dish][:dish_subtype_id] && !DishSubtype.find_by_id(params[:dish][:dish_subtype_id])
        
        dish_category = DishType.find_by_id(params[:dish][:dish_type_id]).name
        params[:dish][:dish_category_id] = DishCategory.find_by_name(dish_category) ? DishCategory.find_by_name(dish_category).id : DishCategory.create(:name => dish_category).id
        params[:dish][:created_by_user] = params[:review][:user_id]
        return render :json => {:error => {:description => 'Dish create error', :code => 6}} unless params[:review][:dish_id] = Dish.create(params[:dish]).id
        
        Tag.get_all.each {|t| DishTag.create(:tag_id => t[:id], :dish_id => params[:review][:dish_id]) if params[:dish][:name].split.map(&:downcase).include?(t[:name])} 

      end
      return render :json => {:error => {:description => 'Dish not found', :code => 7}} unless Dish.find_by_id(params[:review][:dish_id])
      
      if params[:review][:user_id]
        Review.new.save_review(params[:review])
      else
        return render :json => {:error => {:description => 'User not found', :code => 69}}
      end
    else
      $error = {:description => 'Parameters missing', :code => 8}
  end
  return render :json => {
    :error => $error
  } 
  end
  
end