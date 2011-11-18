class Dish < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
  belongs_to :network
  has_many :reviews
  
  # default_scope order('rating/votes DESC, photo DESC')
  
  mount_uploader :photo, ImageUploader
  
  def markers
    self[:id]
    
    # markers = Array.new
    #     dishes.each do |dish|
    #       restaurant = dish.network
    #       marker = "#{restaurant.name}, #{restaurant.lat}, #{restaurant.lon}, #{i}"
    #       markers.push(marker)
    #     end
    #     markers
  end

end
