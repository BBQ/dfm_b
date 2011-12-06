class ApiController < ApplicationController
  
  before_filter :init_error
  
  def init_error
    $error = {:description => nil, :code => nil}
  end
  
  # def trie
  #   words = ['pizza', 'pizza plaza', 'potato', 'pomidor', 'pool', 'pets']
  #   trie = Trie.new
  #   words.each do |word|
  #     trie.add word
  #   end
  # end
  
  def get_user_id
    if params[:id] && params[:provider]
      user = User.find_by_facebook_id(params[:id]).id if params[:provider] = 'facebook'
    end
    return render :json => {
          :user_id => user, 
          :error => $error
    }
  end
  
  def get_dish
    if params[:dish_id]
      user_id = User.find_by_id(User.new.get_user_by_fb_token(params[:access_token])).id if params[:access_token]      
      return render :json => API.get_dish(user_id,params[:dish_id])
    else
      return render :json => {:error => $error}
    end
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
      return render :json => Restaurant.api_get_restaurant(id, type)
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
    
    dishes ||= Dish    
    dishes = dishes.search_for_keyword(search) unless search.blank?
    dishes = dishes.order('dishes.rating/dishes.votes DESC, dishes.votes DESC')
  
    count = dishes.count
    dishes = dishes.limit("#{offset}, #{limit}")
    
    restaurants = []
    dishes.each do |dish|
      dish.network.restaurants.near(params[:lat], params[:lon], radius).take(3).each do |r|
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
    
    # filters = []
    # if params[:bill] && params[:bill].length == 5
    #   bill = []
    #   bill.push('bill = "до 500 руб"') if params[:bill][0] == '1'
    #   bill.push('bill = "500 - 1000 руб"') if params[:bill][1] == '1'
    #   bill.push('bill = "1000 - 2000 руб"') if params[:bill][2] == '1'
    #   bill.push('bill = "2000 - 5000 руб"') if params[:bill][3] == '1'
    #   bill.push('bill = "более 5000 руб"') if params[:bill][4] == '1'
    #   filters.push(bill.join(' OR ')) if bill.count > 0
    # end
    # 
    # etc = []
    # etc.insert(0,'wifi = 1') if params[:wifi] == '1'
    # etc.push(0,'terrace = 1') if params[:terrace] == '1'
    # etc.push(0,'cc = 1') if params[:accept_bank_cards] == '1'
    # filters.push(etc.join(' AND ')) if etc.count > 0
    # all_filters = filters.join(' AND ')
    
    # if params[:open_now]
    #   wday = Date.today.strftime("%a").downcase
    #   now = Time.now.strftime("%H%M")
    #   open_now = "#{now} BETWEEN REPLACE(LEFT(#{wday},5), ':', '') AND REPLACE(RIGHT(#{wday},5), ':', '')"
    #   
    #   if now.to_i < 1000
    #     now24 = now.to_i + 2400
    #     open_now = open_now + " OR #{now24} BETWEEN REPLACE(LEFT(#{wday},5), ':', '') AND REPLACE(RIGHT(#{wday},5), ':', '')"
    #   end    
    #   all_filters = all_filters ? all_filters + ' AND ' + open_now : open_now
    # end
    
    lat = params[:lat] ||= '55.753548'
    lon = params[:lon] ||= '37.609239'
    radius = params[:radius].to_f != 0 ? params[:radius].to_f: nil
    search = params[:search].blank? ? params[:keyword] : params[:search]
            
    if params[:sort] == 'distance'
      if radius
        restaurants = Restaurant.near(params[:lat], params[:lon], radius).by_distance(params[:lat], params[:lon])
      else
        restaurants = Restaurant.by_distance(params[:lat], params[:lon])
      end     
      restaurants = restaurants.includes(:network).where('lat IS NOT NULL AND lon IS NOT NULL').order("networks.rating/networks.votes DESC, networks.votes DESC")
    else
      if radius
        restaurants = Restaurant.near(params[:lat], params[:lon], radius).includes(:network)
      else
        restaurants = Restaurant.includes(:network)
      end
      restaurants = restaurants.order("networks.rating/networks.votes DESC, networks.votes DESC").by_distance(params[:lat], params[:lon]).group('restaurants.name')
    end    
       
    restaurants = restaurants.search_for_keyword(search) unless search.blank?
    # restaurants = restaurants.where(all_filters) unless all_filters.blank?
    
    if restaurants
      count = params[:sort] != 'distance' ? restaurants.count.count : restaurants.count
      restaurants = restaurants.limit("#{offset}, #{limit}") 
    end

    return render :json => {
          :restaurants => restaurants.as_json, 
          :count => count,
          :error => $error
    }
  end
  
  def upload_photo
    if params[:uuid] && params[:photo]     
      $error = {:description => 'Не удается загрузить изображание', :code => 9} unless Image.create({:photo => params[:photo], :uuid => params[:uuid]})           
    else
      $error = {:description => 'Отсутствуют основные параметры', :code => 8}
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
      reviews = reviews.limit("#{offset}, #{limit}")
      
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
    reviews = Review.limit("#{offset}, #{limit}").order('id').includes(:dish).where('photo IS NOT NULL')
    user_id = User.new.get_user_by_fb_token(params[:access_token]) if params[:access_token]
        
    review_data = []
    if params[:lat] && params[:lon]
      restaurants = Restaurant.near(params[:lat], params[:lon], 100).map(&:reviews)
      restaurants.each do |reviews|
        reviews.each do |review|
          review_data.push(review.format_review_for_api(user_id))
        end
      end
    else
      reviews.each do |review|
        review_data.push(review.format_review_for_api(user_id))
      end
    end
    
    return render :json => {
      :reviews => review_data,
      :error => $error
    }
          
  end
  
  def like_review
    if params[:review_id] && params[:access_token]
      user_id = User.new.get_user_by_fb_token(params[:access_token])   
      data = Like.new.save_me(user_id, params[:review_id])
      code = data[:error] ? 11 : nil
    end
    return render :json => {
      :error => {:description => data[:error], :code => code}
    }
  end
  
  def comment_on_review
    if params[:comment] && params[:review_id] && params[:access_token]
      user_id = User.new.get_user_by_fb_token(params[:access_token])
      comment = Comment.create({:user_id => user_id, :review_id => params[:review_id], :text => params[:comment]})                
    end
    return render :json => {
      :error => $error
    }
  end
  
  def get_restaurant_menu
    if params[:restaurant_id]
      
      # dishes = Dish.where('restaurant_id = ?', params[:restaurant_id])
      
      # if dishes.count == 0
        network_id = Restaurant.find_by_id(params[:restaurant_id]).network.id
        dishes = Dish.where('network_id = ?', network_id)
      # end
      
      categories = Array.new(0,Hash.new)
      types = Array.new(0,Hash.new)
      
      dishes.group(:dish_category_id).each do |dish|
        categories.push({:id => dish.dish_category.id, :name => dish.dish_category.name})
      end
      
      dishes.group(:dish_type_id).each do |dish|
        types.push({:id => dish.dish_type.id, :name => dish.dish_type.name})
      end
      
      return render :json => {
        :dishes => dishes.as_json(:only => [:id, :name, :dish_category_id, :dish_type_id, :description, :rating, :votes, :price, :photo]), 
        :categories => categories.as_json(),
        :types => types.as_json(),
        :error => $error
      }
    else
      $error = {:description => 'Отсутствуют основные параметры', :code => 8}  
    end
    return render :json => {
      :error => $error
    }
  end
  
  def add_review
    if params[:review] && params[:review][:restaurant_id] && params[:review][:rating] && params[:access_token]
      params[:review][:user_id] = User.new.get_user_by_fb_token(params[:access_token])
      
      chk24 = Review.where("user_id = ? AND dish_id = ? AND created_at > ?",params[:review][:user_id], params[:review][:dish_id], 1.day.ago)
        # return render :json => {:error => {:description => 'Ревью для блюда можно оставлять 1 раз в 24 часа', :code => 666}}
      return render :json => chk24
      params[:review][:network_id] = Restaurant.find_by_id(params[:review][:restaurant_id])[:network_id]
      
      return render :json => {:error => {:description => 'Ресторан не найден', :code => 1}} unless Restaurant.find_by_id(params[:review][:restaurant_id])
      return render :json => {:error => {:description => 'Не верный рейтинг', :code => 2}} if params[:review][:rating].to_i > 10 || params[:review][:rating].to_i < 1

      if params[:uuid] && image = Image.find_by_uuid(params[:uuid])
        params[:review][:photo] = File.open(image.photo.file.file)  
        image.destroy
      end
    
      if !params[:review][:dish_id] && params[:dish][:name] # && params[:dish][:type_id] && params[:dish][:subtype_id]
        params[:dish][:network_id] = params[:review][:network_id]
        params[:dish][:restaurant_id] = params[:review][:restaurant_id]
        params[:dish][:dish_type_id] = 9 #добавлено пользователем
        params[:dish][:dish_category_id] = 120 # прочее
        # return render :json => {:error => {:description => 'Тип блюда не найден', :code => 4}} unless Type.find_by_id(params[:dish][:type_id])
        # return render :json => {:error => {:description => 'Подтип блюда не найден', :code => 5}} unless Subtype.find_by_id(params[:dish][:subtype_id])
        return render :json => {:error => {:description => 'Ошибка при создании блюда', :code => 6}} unless params[:review][:dish_id] = Dish.create(params[:dish]).id
      end
      return render :json => {:error => {:description => 'Блюдо не найдено', :code => 7}} unless Dish.find_by_id(params[:review][:dish_id])
      
      if params[:review][:user_id]
        Review.new.save_review(params[:review])
      else
        return render :json => {:error => {:description => 'Пользователь не найден', :code => 69}}
      end
    else
      $error = {:description => 'Отсутствуют основные параметры', :code => 8}
  end
  return render :json => {
    :error => $error
  } 
  end
  
end