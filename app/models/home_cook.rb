class HomeCook < ActiveRecord::Base
    
    belongs_to :dish_type
    belongs_to :dish_subtype
    belongs_to :dish_extratype
    has_many :reviews, :dependent => :destroy, :foreign_key => :dish_id
    
    has_many :home_cook_tags, :dependent => :destroy
    has_many :tags, :through => :dish_tags
    
    mount_uploader :photo, ImageUploader
    
    
    def self.favourite(ids_array)
      
      dishes_array = []
      home_cooked = select([:id, :name, :rating, :votes, :photo, :created_at]).where("id in (#{ids_array})").order('id DESC')

      home_cooked.each do |d|

        if current_user_id > 0
          favourite = 1 if Favourite.find_by_user_id_and_home_cook_id(current_user_id, d.id)
        end

        dishes_array.push({
          :id => d.id,
          :name => d.name,
          :rating => d.rating,
          :votes => d.votes,
          :image_sd => d.image_sd,
          :image_hd => d.image_hd,
          :network => {},
          :created_at => d.created_at,
          :type => 'home_cooked',
          :favourite => favourite
        })
      end
      
      dishes_array
    end
    
    def self.expert(top_user_id, current_user_id = 0)
      
      dishes_array = []
      home_cooked = select([:id, :name, :rating, :votes, :photo, :created_at]).where("top_user_id = ?",top_user_id).order('id DESC')

      home_cooked.each do |d|

        if current_user_id > 0
          favourite = 1 if Favourite.find_by_user_id_and_home_cook_id(current_user_id, d.id)
        end

        dishes_array.push({
          :id => d.id,
          :name => d.name,
          :rating => d.rating,
          :votes => d.votes,
          :image_sd => d.image_sd,
          :image_hd => d.image_hd,
          :network => {},
          :created_at => d.created_at,
          :type => 'home_cooked',
          :favourite => favourite
        })
      end
      
      dishes_array
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
