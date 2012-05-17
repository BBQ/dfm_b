class DishCategory < ActiveRecord::Base
  has_many :dishes
  has_many :dish_deliveries, :foreign_key => :id
  has_many :dish_category_order, :dependent => :destroy
  
  def self.get_id_for(name)
    category = find_by_name(name) || create(:name => name)
    category.id
  end
  
end
