class MapController < ApplicationController
  
  def index
    @markers = []
    reviews = Review.select([:lat, :lng]).where("lat > 55.5 && lat < 55.9 && lng > 37.35 && lng < 38").each { |r| @markers.push("['#{r.lat}, #{r.lng}', #{r.lat}, #{r.lng}, 1]")}
    @markers = "[#{@markers.join(',')}]"
  end
  
end
