class DishesController < ApplicationController
  def index
    per_page = 24
    @page = params[:page].to_i
    @review = Review.new
    @k = @page == 0 ? 0 : (@page - 1) * per_page
    
    if params[:search] && params[:search][:find]
      @dishes = Dish.where("LOWER(name) REGEXP '[[:<:]]#{params[:search][:find].downcase}'").order('rating DESC, votes DESC, photo DESC').page(@page).per(per_page)
      @search = params[:search][:find]
    else
      @dishes = Dish.order('rating DESC, photo DESC').page(@page).per(per_page)
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
    
end
