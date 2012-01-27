class ReviewsController < ApplicationController
  
  def index
    @reviews = Review.order('id DESC')
    @i_like = Like.where("user_id = ?", current_user.id) if current_user
    
    # return render :json => @reviews.as_json 
  end
  
  def search
    if params[:type] && params[:search][:find]
      @reviews = Review.where("dish_id IN (SELECT id FROM dishes WHERE LOWER(name) REGEXP '[[:<:]]#{params[:search][:find].downcase}')").order('rating DESC')
      @i_like = Like.where("user_id = ?", current_user.id) if current_user
    end
  end
  
  def show
    @review = Review.find_by_id(params[:id])
    @networks = Network.find_by_id(@review.network_id)
    @networks = Network.find_by_id(Restaurant.find_by_id(@review.restaurant_id)[:network_id]) unless @networks
    @restaurants = Restaurant.where("network_id = ?", @networks.id).count
    
    @markers = Array.new
    @review.network.restaurants.take(2).each do |restaurant|
      @markers.push("['#{restaurant.name}', #{restaurant.lat}, #{restaurant.lon}, 1]")
    end
    @markers = '['+@markers.join(',')+']'
  end
  
  def delete
    if review = Review.find_by_id(params[:id])
      data = review.delete
    end
    return render :json => data
  end
  
end
