class DishesController < ApplicationController
  def index
    @review = Review.new
    @dishes = Dish.order('rating/votes DESC, photo DESC').limit('100')
  end
  
  def show
    @dish = Dish.find_by_id(params[:id])
  end
    
end
