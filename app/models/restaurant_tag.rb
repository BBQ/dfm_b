class RestaurantTag < ActiveRecord::Base
  validates :tag_id, :uniqueness => {:dish_id}
end
