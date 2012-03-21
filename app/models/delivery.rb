class Delivery < ActiveRecord::Base
  has_many :dish_deliveries
  
  has_many :deliveries_tags, :dependent => :destroy
  has_many :tags, :through => :deliveries_tags
  
  def find_image
    unless photo
      
      if dish = DishDelivery.select([:id, :photo]).where("photo IS NOT NULL AND delivery_id = ?", delivery_id).order('rating DESC, votes DESC')
        photo = dish.first.photo
      
      elsif review = Review.select([:id, :photo]).where("restaurant_id = ? AND rtype = 'delivery'", delivery_id).order('count_likes DESC')
        photo = review.first.photo
      
      end
    end
    
    photo
  end
  
  def thumb
    find_image && find_image.p120.url != '/images/noimage.jpg' ? find_image.p120.url  : ''
  end
  
end
