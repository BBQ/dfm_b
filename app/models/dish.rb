class Dish < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
  belongs_to :network
  has_many :reviews
  
  mount_uploader :photo, ImageUploader
  
  def find_image
    if photo.blank?
      review = Review.where("dish_id = ?", id).order('count_likes DESC').first.photo
    else
      photo
    end
  end
  
end
