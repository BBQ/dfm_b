class NetworksController < ApplicationController
  
  def index
    
    per_page = 18
    @networks = Network.order('rating/votes DESC, votes DESC').page(params[:page]).per(per_page)
    @j = params[:page].to_i == 0 ? 0 : (params[:page].to_i - 1) * per_page
    
    @markers = Array.new
    @networks.first.restaurants.each do |restaurant|
      @markers.push("['#{restaurant.name}', #{restaurant.lat}, #{restaurant.lon}, 1]")
    end
    @markers = '['+@markers.join(',')+']'
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
