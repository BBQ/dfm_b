class MapController < ApplicationController
  
  def index
    @markers = []
    reviews = Review.select([:lat, :lng]).where("lat > 55 && lat < 56 && lng > 37 && lng < 38").each { |r| @markers.push("['#{r.lat}, #{r.lng}', #{r.lat}, #{r.lng}, 1]")}
    @markers = "[#{@markers.join(',')}]"
  end
  
end
