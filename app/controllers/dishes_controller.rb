class DishesController < ApplicationController
  def index
    per_page = 24
    @review = Review.new
    @k = params[:page].to_i == 0 ? 0 : (params[:page].to_i - 1) * per_page
    @dishes = Dish.order('rating/votes DESC, photo DESC').page(params[:page]).per(per_page)
    
    @markers = Array.new
    @dishes.first.network.restaurants.each do |restaurant|
      @markers.push("['#{restaurant.name}', #{restaurant.lat}, #{restaurant.lon}, 1]")
    end
    @markers = '['+@markers.join(',')+']'
  end
  
  def show
    @dish = Dish.find_by_id(params[:id])
  end
    
end
