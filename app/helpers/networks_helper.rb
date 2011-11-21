module NetworksHelper
  
  def image_url(network)
      restaurant_image = network.restaurants.first.restaurant_images.first
      if restaurant_image && restaurant_image.photo
        image_url = network.restaurants.first.restaurant_images.first.photo_url
      elsif network.dishes.count > 0 && !network.dishes.first.photo.blank?
        image_url = network.dishes.order('rating/votes DESC, votes DESC, photo DESC').first.photo_url
      elsif network.reviews.count > 0 && !network.reviews.first.photo.blank?
        image_url = network.reviews.order('count_likes DESC, photo DESC').first.photo_url
  		else
  		  image_url = network.restaurants.first.photo_url
  	  end
  	  image_url
	end
  
end
