class DishfeedController < ApplicationController
  def index
    @reviews = Review.order('id DESC')
    @i_like = Like.where("user_id = ?", current_user.id) if current_user
    
    # return render :json => @reviews.as_json 
  end
end
