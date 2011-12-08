class NetworksController < ApplicationController
  
  def index
    per_page = 18
    @page = params[:page].to_i
    @j = @page == 0 ? 0 : (@page - 1) * per_page
    
    if params[:search] && params[:search][:find]
      @networks = Network.where("LOWER(name) REGEXP '[[:<:]]#{params[:search][:find].downcase}'").order('rating DESC, votes DESC').page(@page).per(per_page)
      @search = params[:search][:find]
    else
      @networks = Network.order('rating DESC, votes DESC').page(@page).per(per_page)
    end
    
    unless @networks.blank?
      @markers = Array.new
      @networks.first.restaurants.each do |restaurant|
        @markers.push("['#{restaurant.name}', #{restaurant.lat}, #{restaurant.lon}, 1]")
      end
      @markers = '['+@markers.join(',')+']'
    end
  end
  
  def show
    @network = Network.find_by_id(params[:id])
    @dishes = @network.dishes
  end
  
  def dishes
    @network = Network.find_by_id(params[:id])
    @dishes = @network.dishes
  end  
  
  def menu
    @network = Network.find_by_id(params[:id])
    @dishes = @network.dishes
    @categories = @network.dishes.group('dish_category_id')
  end
  
  def reviews
    @network = Network.find_by_id(params[:id])
    @review = Review.find_by_network_id(params[:id])
  end
  
  def addresses
    @network = Network.find_by_id(params[:id])
  end
  
end
