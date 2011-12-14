class DishSubtype < ActiveRecord::Base
  has_many :dishes
  belongs_to :dish_type
  
  def as_json(options={}) 
    super(:only => [:id, :name], :include => {:dish_type => {:only => [:id, :name]}})
  end
  
end
