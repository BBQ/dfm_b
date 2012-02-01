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
      
  mount_uploader :photo, ImageUploader
  
  def self_review
    
    get_likes = []
    DishLike.all.each do |dl|
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
    DishComment.all.each do |dc|
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
    where("id IN (SELECT dish_id FROM dish_tags WHERE id = ?)", id)
  end
  
  def self.custom_search(keyword_or_id)
    ids = {
      1 => ['салат','salad','салатик'],
      2 => ['soup','суп','супы','супчик','супчики','супец'],
      3 => ['pasta','паста','пасты','спагетти'],
      4 => ['pizza','пицца','пиццы'],
      5 => ['burger','бургер'],
      6 => ['noodles','лапша'],
      7 => ['risotto','ризотто'],
      8 => ['rice','рис'],
      9 => ['steak','стейк','стэйк'],
      10 => ['sushi & rolls','суши и роллы','суши','sushi','ролл','сашими'],
      11 => ['desserts','десерт','торт','пирожные','пирожное','выпечка','мороженое','пирог','сладости','сорбет'],
      12 => ['drinks','напитки','напиток'],
      13 => ['meat','мясо','мясное'],
      14 => ['fish','рыба','морепродукты','креветки','мидии','форель','треска','карп','моллюски','устрицы','сибас','лосось','судак'],
      15 => ['vegetables','овощи','овощь']
    }
    
    condition = 'dishes.id IN (SELECT dish_id FROM dish_tags WHERE tag_id = ?)'
    
    if keyword_or_id.to_i != 0
      id = keyword_or_id
      where(condition, id)
    else
      keyword = keyword_or_id.downcase
      id = 0
      
      ids.each {|k,v| id = k if v.include?(keyword)}        

      if id == 0 && tag = Tag.find_by_name(keyword)
        id = tag.id
      end
      
      if id != 0
        where(condition, id)
      else
        if word = SearchWord.find_by_name(keyword)
          word.count += 1
          word.save
        else
          SearchWord.create(:name => keyword, :count => 1)
        end

        where("dish_category_id IN (SELECT DISTINCT id FROM dish_categories WHERE LOWER(dish_categories.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]') 
              OR 
              dishes.dish_type_id IN (SELECT DISTINCT id FROM dish_types WHERE LOWER(dish_types.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
              OR
              dishes.dish_subtype_id IN (SELECT DISTINCT id FROM dish_subtypes WHERE LOWER(dish_subtypes.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]')
              OR 
              LOWER(dishes.`name`) REGEXP '[[:<:]]#{keyword}[[:>:]]'")    
      end
      
    end
  end
  
end
