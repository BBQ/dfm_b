class DishTag < ActiveRecord::Base
  belongs_to :dish
  belongs_to :tag
  
  validates :dish_id, :uniqueness => {:tag_id}
end
