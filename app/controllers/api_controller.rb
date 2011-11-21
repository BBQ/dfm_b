class ApiController < ApplicationController
  
  before_filter :init_error
  
  def init_error
    $error = {:description => nil, :code => nil}
  end
  
  def get_restaurants
    
    limit = params[:limit] ? params[:limit] : 25
    offset = params[:offset] ? params[:offset] : 0
            
    if params[:lat] && params[:lon]
      restaurants = Restaurant.where('lat IS NOT NULL AND lon IS NOT NULL').by_distance(params[:lat], params[:lon])
    else
      restaurants = Restaurant.order('rating/votes DESC')
    end
    
    restaurants = restaurants.where("name LIKE ?", "%#{params[:search]}%") unless params[:search].blank?
    count = restaurants.count
    restaurants = restaurants.limit("#{offset}, #{limit}")
    
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
  
  def get_reviews
  
    limit = params[:limit] ? params[:limit] : 25
    offset = params[:offset] ? params[:offset] : 0
    reviews = Review.limit("#{offset}, #{limit}").order('id').includes(:dish)
    user_id = User.new.get_user_by_fb_token(params[:access_token]) if params[:access_token]
        
    review_data = Array.new
    if params[:lat] && params[:lon]
      restaurants = Restaurant.near(params[:lat], params[:lon], 100).map(&:reviews)
      restaurants.each do |reviews|
        reviews.each do |review|
          data = Hash.new
          data[:review_id] = review.id
          data[:dish_name] = review.dish.name
          data[:restaurant_name] = review.restaurant.name
          data[:user_name] = review.user.name
          data[:user_facebook_id] = review.user.facebook_id  
          data[:likes] = review.count_likes
          data[:comments] = review.count_comments
          data[:rating] = review.rating
          data[:image_sd] = review.photo.iphone.url
          data[:image_hd] = review.photo.iphone_retina.url
          data[:liked] = user_id && Like.find_by_user_id_and_review_id(user_id, review.id) ? 1 : 0
          review_data.push(data)
        end
      end
    else
      reviews.each do |review|
        data = Hash.new
        data[:review_id] = review.id
        data[:dish_name] = review.dish.name
        data[:restaurant_name] = review.restaurant.name
        data[:user_name] = review.user.name
        data[:user_facebook_id] = review.user.facebook_id  
        data[:likes] = review.count_likes
        data[:comments] = review.count_comments
        data[:rating] = review.rating
        data[:image_sd] = review.photo.iphone.url
        data[:image_hd] = review.photo.iphone_retina.url
        data[:liked] = user_id && Like.find_by_user_id_and_review_id(user_id, review.id) ? 1 : 0   
        review_data.push(data)
      end
    end
    
    return render :json => {
      :reviews => review_data,
      :error => $error
    }
          
  end
  
  def like_review
    user_id = User.new.get_user_by_fb_token(params[:access_token]) if params[:access_token]    
    data = Like.new.save_me(user_id, params[:review_id]) if params[:review_id] && user_id
    code = data[:error] ? 11 : nil
    return render :json => {
      :error => {:description => data[:error], :code => code}
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
    if params[:uuid] && params[:review][:restaurant_id] && params[:review][:rating] && params[:access_token]
      params[:review][:network_id] = Restaurant.find_by_id(params[:review][:restaurant_id])[:network_id]
      
      return render :json => {:error => {:description => 'Ресторан не найден', :code => 1}} unless Restaurant.find_by_id(params[:review][:restaurant_id])
      return render :json => {:error => {:description => 'Не верный рейтинг', :code => 2}} if params[:review][:rating].to_i > 10 || params[:review][:rating].to_i < 1

      if image = Image.find_by_uuid(params[:uuid])
        params[:review][:photo] = File.open(image.photo.file.file)  
        image.destroy
      else
        return render :json => {:error => {:description => 'Пожалуйста подождите, фото ещё не загрузилось. =)', :code => 3}}
      end
    
      if !params[:review][:dish_id] && params[:dish][:name] # && params[:dish][:type_id] && params[:dish][:subtype_id]
        params[:dish][:network_id] = params[:review][:network_id]
        # params[:dish][:rating] = params[:review][:rating]
        params[:dish][:restaurant_id] = params[:review][:restaurant_id]
        params[:dish][:dish_type_id] = 9 #добавлено пользователем
        params[:dish][:dish_category_id] = 120 # прочее
        # return render :json => {:error => {:description => 'Тип блюда не найден', :code => 4}} unless Type.find_by_id(params[:dish][:type_id])
        # return render :json => {:error => {:description => 'Подтип блюда не найден', :code => 5}} unless Subtype.find_by_id(params[:dish][:subtype_id])
        return render :json => {:error => {:description => 'Ошибка при создании блюда', :code => 6}} unless params[:review][:dish_id] = Dish.create(params[:dish]).id
      end
      return render :json => {:error => {:description => 'Блюдо не найдено', :code => 7}} unless Dish.find_by_id(params[:review][:dish_id])

      params[:review][:user_id] = User.new.get_user_by_fb_token(params[:access_token])
      
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