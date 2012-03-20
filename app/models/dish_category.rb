class DishCategory < ActiveRecord::Base
  has_many :dishes
  has_many :dish_deliveries
  
  def get_id(name)
    unless id = find_by_name(name)
      id = create(:name => name).id
    end
    id
  end
  
end
