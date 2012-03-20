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
  
  def create(data, delivery_id)
    unless dish = find_by_name_and_delivery_id(data[:name], delivery_id)
      
      if type = DishType.find_by_id(data[:dish_type_id])
        data[:dish_category_id] = DishCategory.get_id(type.name)
      end
      dish.match_tags if dish = create(data)    
      
    end
  end
  
  def match_tags
    
    system "rake tags:match_dishes NETWORK_ID='#{network_id} DISH_ID='#{id}' TYPE='delivery' &"
    system "rake tags:match_rest NETWORK_ID='#{network_id} DISH_ID='#{id}' TYPE='delivery' &"
    
    # Tag.all.each do |t|
    # 
    #   tags_array = []      
    #   tags_array.push("\\b#{t.name_a}\\b") unless t.name_a.blank? 
    #   tags_array.push("\\b#{t.name_b}\\b") unless t.name_b.blank? 
    #   tags_array.push("\\b#{t.name_c}\\b") unless t.name_c.blank? 
    #   tags_array.push("\\b#{t.name_d}\\b") unless t.name_d.blank? 
    #   tags_array.push("\\b#{t.name_e}\\b") unless t.name_e.blank? 
    #   tags_array.push("\\b#{t.name_f}\\b") unless t.name_f.blank? 
    #   tags = tags_array.join('|')
    #   
    #   if !name.scan(/#{tags}/i).blank? || (dish_category && !dish_category.name.scan(/#{tags}/i).blank?) || (dish_type && !dish_type.name.scan(/#{tags}/i).blank?) || (dish_subtype && !dish_subtype.name.scan(/#{tags}/i).blank?)
    #     DishDeliveryTag.create({:tag_id => t.id, :dish_id => id})
    #   end
    #   
    # end
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
