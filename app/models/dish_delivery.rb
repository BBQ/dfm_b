class DishDelivery < ActiveRecord::Base
  
  belongs_to :dish_category, :foreign_key => :dish_category_id
  belongs_to :dish_type, :foreign_key => :dish_type_id
  belongs_to :dish_subtype, :foreign_key => :dish_subtype_id
  belongs_to :dish_extratype, :foreign_key => :dish_extratype_id  
  
  has_many :reviews, :dependent => :destroy, :foreign_key => :dish_id
  has_many :dish_delivery_likes, :dependent => :destroy
  has_many :dish_delivery_comments, :dependent => :destroy
  
  has_many :dish_delivery_tags, :dependent => :destroy
  has_many :tags, :through => :dish_tags
  
  belongs_to :delivery
  
  mount_uploader :photo, ImageUploader
  
  def self.search_by_tag_id(id)
    where("dish_deliveries.id IN (SELECT dish_id FROM dish_tags WHERE tag_id = ?)", id)
  end
  
  def self.create(data)
    unless dish = find_by_name_and_delivery_id(data[:name], data[:delivery_id])

      if dtype = DishType.select(:name).find_by_id(data[:dish_type_id])
        data[:dish_category_id] = DishCategory.get_id(dtype.name)
      end
      dish.match_tags if dish = super(data)    
      
    end
    dish
    
  end
  
  def match_tags
    Tag.all.each do |t|
    
      tags_array = []      
      tags_array.push("\\b#{t.name_a}\\b") unless t.name_a.blank? 
      tags_array.push("\\b#{t.name_b}\\b") unless t.name_b.blank? 
      tags_array.push("\\b#{t.name_c}\\b") unless t.name_c.blank? 
      tags_array.push("\\b#{t.name_d}\\b") unless t.name_d.blank? 
      tags_array.push("\\b#{t.name_e}\\b") unless t.name_e.blank? 
      tags_array.push("\\b#{t.name_f}\\b") unless t.name_f.blank? 
      tags = tags_array.join('|')
      
      if !name.scan(/#{tags}/i).blank? || (dish_category && !dish_category.name.scan(/#{tags}/i).blank?) || (dish_type && !dish_type.name.scan(/#{tags}/i).blank?) || (dish_subtype && !dish_subtype.name.scan(/#{tags}/i).blank?)
        DishTag.create({:tag_id => t.id, :dish_id => id})
      end  
    end
    
    system "rake tags:match_rest NETWORK_ID='#{delivery_id} DISH_ID='#{id}' TYPE='delivery' &"
    
  end
  
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
