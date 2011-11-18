class NetworksController < ApplicationController
  
  def index
    per_page = 15
    @networks = Network.order('rating/votes DESC, votes DESC').page(params[:page]).per(per_page)
    # @markers = 
    @networks.each do |network|
      if network.restaurants.first.restaurant_images.first
        @image_url = network.restaurants.first.restaurant_images.first.photo_url
      elsif !network.dishes.blank?
        @image_url = network.dishes.order('photo DESC, rating/votes DESC').first.photo_url
      elsif !network.reviews.blank?
        @image_url = network.reviews.order('photo DESC, count_likes DESC').first.photo_url
  		else
  		  @image_url = network.restaurants.first.photo_url
  	  end
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
