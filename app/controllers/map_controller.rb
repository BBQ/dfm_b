class MapController < ApplicationController
  
  def index
    @markers = []
    reviews = Review.select([:lat, :lng]).where("lat > 54 && lat < 56").each { |r| @markers.push("['review', #{r.lat}, #{r.lng}, 1]")}
    @markers = "[#{@markers.join(',')}]"
  end
  
end
