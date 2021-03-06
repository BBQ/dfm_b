# encoding: utf-8
class Dish < ActiveRecord::Base
    
  belongs_to :dish_category
  belongs_to :dish_type
  belongs_to :dish_subtype
  belongs_to :dish_extratype
  
  has_many :reviews, :dependent => :destroy
  has_many :dish_likes, :dependent => :destroy
  has_many :dish_comments, :dependent => :destroy
  
  belongs_to :network
  has_many :restaurants, :through => :network    
  
  has_many :dish_tags, :dependent => :destroy
  has_many :tags, :through => :dish_tags
  has_many :favourites, :dependent => :destroy
      
  mount_uploader :photo, ImageUploader
  
  def self.create(data)
    
    unless dish = find_by_name_and_network_id(data[:name], data[:network_id])  
      if data[:created_by_user]
        
        if dish_type = DishType.select(:name).find_by_id(data[:dish_type_id])
          data[:dish_category_id] = DishCategory.get_id_for dish_type.name
        end      
        dish.match_tags if dish = super(data)
        
      else
        
        dish = super(data) 
        
      end       
    end
    dish
  
  end
  
  def self.favourite(ids_array)
    
    dishes_array = []
    dishes = select([:id, :name, :rating, :votes, :photo, :network_id, :fsq_checkins_count, :created_at]).where("id in (#{ids_array})").order('id DESC')

    dishes.each do |d|
      network_data = Network.select([:id, :name]).find_by_id(d.network_id)
      
      dishes_array.push(
        :id => d.id,
        :name => d.name,
        :rating => d.rating,
        :votes => d.votes,
        :image_sd => d.image_sd,
        :image_hd => d.image_hd,
        :favourite => 1,
        :network => {
          :id => network_data.id,
          :name => network_data.name,
        },
        :created_at => d.created_at,
        :type => nil
      )
    end
    
    dishes_array
  end
  
  def self.expert(top_user_id, current_user_id = 0)
    
    dishes_array = []
    dishes = select([:id, :name, :rating, :votes, :photo, :network_id, :fsq_checkins_count, :created_at]).where(:top_user_id => top_user_id).order('id DESC')

    dishes.each do |d|
      network_data = Network.select([:id, :name]).find_by_id(d.network_id)

      if current_user_id > 0
        favourite = 1 if Favourite.find_by_user_id_and_dish_id(current_user_id, d.id)
      end
      
      dishes_array.push(
        :id => d.id,
        :name => d.name,
        :rating => d.rating,
        :votes => d.votes,
        :image_sd => d.image_sd,
        :image_hd => d.image_hd,
        :favourite => favourite,
        :network => {
          :id => network_data.id,
          :name => network_data.name,
        },
        :created_at => d.created_at,
        :type => nil
      )
    end
    
    dishes_array
  end
  
  def self_review
    
    get_likes = []
    dish_likes.each do |dl|
      get_likes.push({
        :id => dl.id,
        :user => {
          :id => dl.user_id,
          :name => dl.user.name,
          :user_photo => dl.user.user_photo
        }
      })
    end
    
    get_comments = []
    dish_comments.each do |dc|
      get_comments.push({
        :id => dc.id,
        :text => dc.text,
        :created_at => dc.created_at.to_i,
        :user => {
          :id => dc.user_id,
          :name => dc.user.name,
          :user_photo => dc.user.user_photo
        }
      })
    end
    
    data = {
      :review => {
        :user_id => 1,
        :likes => get_likes,
        :comments => get_comments
      }
    }
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
    
    system "rake tags:match_rest NETWORK_ID='#{network_id}' DISH_ID='#{id}' &"
    
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
  
  def image_p120
    image = find_image && find_image.thumb.url != '/images/noimage.jpg' ? find_image.thumb.url : ''
  end
  
  def image_hd
    find_image && find_image.iphone_retina.url != '/images/noimage.jpg' ? find_image.iphone_retina.url  : ''
  end
  
  def self.near(lat, lon, rad = 1)
    where("((ACOS(
      SIN(restaurants.lat * PI() / 180) * SIN(? * PI() / 180) + 
      COS(restaurants.lat * PI() / 180) * COS(? * PI() / 180) * 
      COS((? - restaurants.lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344 <= ?", lat, lat, lon, rad)
  end
  
  def self.by_distance(lat, lon)
    order("((ACOS(
      SIN(#{lat} * PI() / 180) * SIN(restaurants.lat * PI() / 180) +
      COS(#{lat} * PI() / 180) * COS(restaurants.lat * PI() / 180) * 
      COS((#{lon} - restaurants.lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344")
  end
  
  def self.search_by_tag_id(id)
    where("dishes.id IN (SELECT dish_id FROM dish_tags WHERE tag_id = ?)", id)
  end
  
  def self.search(keyword)
    keyword.downcase!
    where("(dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE LOWER(dish_categories.`name`) REGEXP '[[:<:]]#{keyword}') 
          OR 
          dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE LOWER(dish_types.`name`) REGEXP '[[:<:]]#{keyword}')
          OR
          dishes.dish_subtype_id IN (SELECT DISTINCT id FROM dish_subtypes WHERE LOWER(dish_subtypes.`name`) REGEXP '[[:<:]]#{keyword}')
          OR 
          LOWER(dishes.`name`) REGEXP '[[:<:]]#{keyword}')")    
  end
  
end
