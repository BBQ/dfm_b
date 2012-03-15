class DishDelivery < ActiveRecord::Base
  
  belongs_to :dish_category, :foreign_key => :dish_id
  belongs_to :dish_type, :foreign_key => :dish_id
  belongs_to :dish_subtype, :foreign_key => :dish_id
  belongs_to :dish_extratype, :foreign_key => :dish_id  
  
  has_many :reviews, :dependent => :destroy, :foreign_key => :dish_id
  has_many :dish_delivery_likes, :dependent => :destroy
  has_many :dish_delivery_comments, :dependent => :destroy
  
  has_many :dish_delivery_tags, :dependent => :destroy
  has_many :tags, :through => :dish_tags
  
  mount_uploader :photo, ImageUploader
end
