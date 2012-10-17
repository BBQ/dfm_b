class MapController < ApplicationController
  
  def index
    @markers = []
    reviews = Review.select([:lat, :lng]).each { |r| @markers.push("['review', #{r.lat}, #{r.lng}, 1]")}
    @markers = "[#{@markers.join(',')}]"
  end
  
end
