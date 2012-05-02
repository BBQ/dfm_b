class RestaurantsController < ApplicationController
  def index
    @restaurants = Restaurant.all
  end
  
  def show
    if @restaurant = Restaurant.find_by_id(params[:id])
          
      @r_categories = RestaurantCategory.where("id IN (#{@restaurant.restaurant_categories})").collect { |c| c.name}.join(', ')
  
      @bill = []
      @restaurant.bill.to_i.times do
        @bill.push('$')
      end
      @bill = @bill.join('')
      
      @fb_obj = @restaurant
            
      @best_dishes = Dish.select([:id, :photo, :name]).where("network_id = ? AND rating > 0", @restaurant.network_id).limit(21).order("rating/votes DESC")
      
      @markers = []
      @restaurant.network.restaurants.select([:name, :lat, :lon]).each { |r| @markers.push("['#{r.name}', #{r.lat}, #{r.lon}, 1]")}
      @markers = "[#{@markers.join(',')}]"
    end
  end
  
end
