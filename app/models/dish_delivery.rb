class DishDelivery < ActiveRecord::Base
  
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
  belongs_to :dish_extratype  
  
  has_many :reviews, :dependent => :destroy, :foreign_key => :dish_id
  has_many :dish_delivery_likes, :dependent => :destroy
  has_many :dish_delivery_comments, :dependent => :destroy
  
  has_many :dish_tags, :dependent => :destroy
  has_many :tags, :through => :dish_tags
  
  mount_uploader :photo, ImageUploader
end
