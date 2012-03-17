class DishTag < ActiveRecord::Base
  belongs_to :dish
  belongs_to :tag
  
  validates :dish_id, :uniqueness => {:scope => :tag_id}
end
