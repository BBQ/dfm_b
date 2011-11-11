class ReviewsController < ApplicationController
  def show
    @review = Review.find_by_id(params[:id])
    @networks = Network.find_by_id(@review.network_id)
    @restaurants = Restaurant.where("network_id = ?", @networks.id).count
  end
  
end
