class DishfeedController < ApplicationController
  def index
    @reviews = Review.all
    @i_like = Like.where("user_id = ?", current_user.id) if current_user
  end
end
