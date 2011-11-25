class ReviewsController < ApplicationController
  
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
    result = "Something wrong with review #{params[:id]} ..."
    if params[:id] 
      
      data = Hash.new
      if review = Review.find_by_id(params[:id])
        rating = review.rating
      
        restaurant_id = review.restaurant_id
        dish_id = review.dish_id
        data[:rating] = rating
                  
        restaurant = Restaurant.find_by_id(restaurant_id)
        data[:rrb] = restaurant.rating
        data[:rvb] = restaurant.votes
        restaurant.rating = restaurant.rating - rating
        restaurant.votes = restaurant.votes - 1
        data[:rra] = restaurant.rating
        data[:rva] = restaurant.votes
      
        network = Network.find_by_id(restaurant.network_id)
        data[:nrb] = network.rating
        data[:nvb] = network.votes
        network.rating = network.rating - rating
        network.votes = network.votes - 1
        data[:nra] = network.rating
        data[:nva] = network.votes
      
        dish = Dish.find_by_id(dish_id)
        data[:drb] = dish.rating
        data[:dvb] = dish.votes      
        dish.rating = dish.rating - rating
        dish.votes = dish.votes - 1
        data[:dra] = dish.rating
        data[:dva] = dish.votes
        
        likes = Like.find_all_by_dish_id(dish_id)
        likes.each do |like|
          like.destroy
        end
        
        comments = Comment.find_all_by_dish_id(dish_id)
        comments.each do |comment|
          comment.destroy
        end
              
        if review && dish && restaurant && network
          
          if dish.dish_type_id == 9 && dish.votes == 0 
            dish.delete
            data[:deleted] = 'yes'
          else
            dish.save
          end
          
          restaurant.save
          network.save
          review.destroy
          
          result = "review with id #{params[:id]} gone forever!"
        end
      end
    end
    
    data[:result] = result
    return render :json => data
  end
  
end
