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
  
  belongs_to :delivery
  
  mount_uploader :photo, ImageUploader
  
  def find_image
    if photo.blank?
      if review = Review.where("dish_id = ? AND photo IS NOT NULL", id).order('count_likes DESC').first
        review.photo
      else
        dish_type.photo if dish_type
      end
    else
      photo
    end
  end

  def image_sd
    find_image && find_image.iphone.url != '/images/noimage.jpg' ? find_image.iphone.url  : ''
  end

  def image_hd
    find_image && find_image.iphone_retina.url != '/images/noimage.jpg' ? find_image.iphone_retina.url  : ''
  end
  
end
