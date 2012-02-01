class DishComment < ActiveRecord::Base
  belongs_to :dish
  belongs_to :user
  
  def delete
    dish.count_comments -= 1
    dish.save
    self.destroy
  end
  
end
