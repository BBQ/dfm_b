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
    @dish = Dish.find_by_id(params[:id])
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
      
      DishTag.where(:dish_id => params[:id]).each {|dt| dt.destroy}
      DishComment.where(:dish_id => params[:id]).each {|dc| dc.destroy}
      DishLike.where(:dish_id => params[:id]).each {|dl| dl.destroy}
      status = 'Cleared' if dish.destroy
      return render :json => status ||= 'SWR :`('
    else
      return render :json => 'Dish not found or already deleted.'
    end
  end
    
end
