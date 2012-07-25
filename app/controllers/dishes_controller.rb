class DishesController < ApplicationController
  def index
    per_page = 24
    @page = params[:page].to_i
    @review = Review.new
    @k = @page == 0 ? 0 : (@page - 1) * per_page
    
    lat = params[:lat] ||= '55.753548'
    lon = params[:lon] ||= '37.609239'
    
    if params[:search] && params[:search][:find]
      @dishes = Dish.where("LOWER(name) REGEXP '[[:<:]]#{params[:search][:find].downcase}'").includes(:network, :restaurants).order('dishes.rating DESC, dishes.votes DESC, networks.rating DESC, networks.votes DESC, dishes.photo DESC, fsq_checkins_count DESC').by_distance(params[:lat], params[:lon]).page(@page).per(per_page)
      @search = params[:search][:find]
    else
      @dishes = Dish.includes(:network, :restaurants).order('dishes.rating DESC, dishes.votes DESC, networks.rating DESC, networks.votes DESC, dishes.photo DESC, fsq_checkins_count DESC').by_distance(params[:lat], params[:lon]).page(@page).per(per_page)
    end
    
    unless @dishes.blank?
      @markers = Array.new
      @dishes.first.network.restaurants.take(10).each do |restaurant|
        @markers.push("['#{restaurant.name}', #{restaurant.lat}, #{restaurant.lon}, 1]")
      end
      @markers = '['+@markers.join(',')+']'
    end
    
  end
  
  def show
    if @dish = Dish.find_by_id(params[:id])
      @restaurant = @dish.network.restaurants.first
      @r_categories = RestaurantCategory.where("id IN (#{@restaurant.restaurant_categories})").collect { |c| c.name}
    
      @bill = []
      @restaurant.bill.to_i.times {@bill.push('$')}
      @bill = @bill.join
      
      @markers = []
      @dish.network.restaurants.select([:name, :lat, :lon]).each { |r| @markers.push("['#{r.name}', #{r.lat}, #{r.lon}, 1]")}
      @markers = "[#{@markers.join(',')}]"
      
      if @dish.photo.blank?
        @review = @dish.reviews.where('photo IS NOT NULL').order('count_likes DESC, rating DESC').first
      end
      
      if !@review
        @review = Review.new
        @review.id = "-#{@dish.id}"
        @review.user_id = 1
        @review.dish_id = @dish.id
        @review.rating = @dish.rating
        @review.text = @dish.description
      end
      
      @fb_obj = @dish
      
      r_arr = Review.where("dish_id = ? AND photo IS NOT NULL",params[:id]).collect {|r| r.id}
      r_arr.push("-#{@dish.id}".to_i) unless @dish.photo.blank?
      
      if next_index = r_arr.find_index(@review.id)
        @review_next_id = r_arr[0] unless @review_next_id = r_arr[next_index + 1]           
      end
      
      if prev_index = r_arr.find_index(@review.id)
        @review_prev_id = r_arr[prev_index - 1]
      end
      
      web = "http://dish.fm"
      url = "#{web}/dishes/#{@dish.id}"
      
      @dish_img = @dish.photo.iphone_retina.url
      img = "#{web}#{@dish_img}" unless @dish_img.blank?
      
      @share_data = {
        :pinit => {
          :url => url,
          :media => img,
          :description => "#{@dish.name}. #{@dish.description}"[0 .. 250]
        },
        :facebook => {
          :url => url
        },
        :twitter => {
          :description => "#{@dish.name}. #{@dish.description}"[0 .. 100]
        }
      }
      
    end
  end
  
  def delete
    if dish = Dish.find_by_id(params[:id])
      
      dish.reviews.each do |r|
        r.restaurant.rating = r.restaurant.votes == 1?0 : (r.restaurant.rating * r.restaurant.votes - r.rating) / (r.restaurant.votes - 1)
        r.restaurant.votes = 1?0 : r.restaurant.votes - 1
        r.restaurant.save
        
        r.network.rating = r.network.votes == 1?0 : (r.network.rating * r.network.votes - r.rating) / (r.network.votes - 1)
        r.network.votes = 1?0 : r.network.votes - 1
        r.network.save
      end

      status = 'Cleared' if dish.destroy
      return render :json => status ||= 'SWR :`('
    else
      return render :json => 'Dish not found or already deleted.'
    end
  end
    
end
