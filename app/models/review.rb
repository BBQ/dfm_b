class Review < ActiveRecord::Base
  belongs_to :dish
  belongs_to :home_cook, :foreign_key => :dish_id
  belongs_to :dish_delivery, :foreign_key => :dish_id
  belongs_to :restaurant
  belongs_to :network
  belongs_to :delivery, :foreign_key => :restaurant_id 
  belongs_to :user
  
  has_many :comments, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  
  mount_uploader :photo, ImageUploader 
  
  def self.near(lat, lng, rad = 1000)
    where("((ACOS(
    	SIN(lat * PI() / 180) * SIN(? * PI() / 180) + 
    	COS(lat * PI() / 180) * COS(? * PI() / 180) * 
    	COS((? - lng) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) * 1.609344 <= ?", lat, lat, lng, rad)
  end
  
  def self.following(user_id)
    where("user_id = ? || user_id IN (SELECT follow_user_id FROM followers WHERE user_id = ?)", user_id, user_id)
  end
  
  def delete
      result = "Something wrong with review #{id} ..."
      data = Hash.new
      
      if review = Review.find_by_id(id)
        
        rating = review.rating
      
        restaurant_id = review.restaurant_id
        dish_id = review.dish_id
        data[:rating] = rating
                  
        if restaurant = Restaurant.find_by_id(restaurant_id)
         
          data[:rrb] = restaurant.rating
          data[:rvb] = restaurant.votes
          restaurant.rating = restaurant.votes == 1?0 : (restaurant.rating * restaurant.votes - rating) / (restaurant.votes - 1)
          restaurant.votes = restaurant.votes == 1?0 : restaurant.votes - 1
          data[:rra] = restaurant.rating
          data[:rva] = restaurant.votes
      
          network = Network.find_by_id(restaurant.network_id)
          data[:nrb] = network.rating
          data[:nvb] = network.votes
          network.rating = network.votes == 1?0 : (network.rating * network.votes - rating) / (network.votes - 1)
          network.votes = network.votes == 1?0 : network.votes - 1
          data[:nra] = network.rating
          data[:nva] = network.votes
          
          top_uid = Review.where('restaurant_id = ? AND id != ?', restaurant.id, review.id).group('user_id').count
          restaurant.top_user_id = top_uid.blank? ? 0 : top_uid.max[0]
          
          restaurant.save
          network.save
          
        end
        
        dish = case review.rtype
          when 'home_cooked' then HomeCook.find_by_id(dish_id)
          when 'delivery' then DishDelivery.find_by_id(dish_id)
          else Dish.find_by_id(dish_id)
        end
        
        data[:drb] = dish.rating
        data[:dvb] = dish.votes      
        dish.rating = dish.votes == 1?0 : (dish.rating * dish.votes - rating) / (dish.votes - 1)
        dish.votes = dish.votes == 1?0 : dish.votes - 1
        data[:dra] = dish.rating
        data[:dva] = dish.votes
              
        if review && dish
          
          if dish.created_by_user != 0 && dish.votes == 0 
             dish.delete
             data[:deleted] = 'yes'
          else    
            top_uid = Review.where('dish_id = ? AND id != ?', dish.id, review.id).group('user_id').count
            dish.top_user_id = top_uid.blank? ? 0 : top_uid.max[0]
            dish.save
          end
          
          APN::Notification.destroy_all(:review_id => review.id)
          review.destroy
          
          result = "review with id #{id} gone forever!"
        end
      end
      data[:result] = result
      data
  end
  
  def as_json(options={})
    self.restaurant.rating = self.network.rating if restaurant && network
    self.restaurant.votes = self.network.votes if restaurant && network
    self.restaurant.photo = self.restaurant.photo.iphone.url if restaurant && restaurant.photo
    self.comments.each {|c| c.created_at = c.created_at.to_i}
        
    super(:only => [:user_id], 
          :include => {
            :likes => {:only => [:id], :include => {:user => { :only => [:id, :name], :methods => :user_photo}}},
            :comments => {:only => [:id, :text, :created_at], :include => {:user => { :only => [:id, :name], :methods => :user_photo}}}
          })
  end
  
  def format_review_for_api(user_id=nil)    
    friends_with = []
    
    if friends
      friends.split(',').each do |u|
        
        if user = User.find_by_id(u)
          friends_with.push({
            :id => user.id,
            :name => user.name,
            :photo => user.user_photo
          })
        elsif user = u.split('@@@')
          user[0] = "http://graph.facebook.com/#{user[0]}/picture?type=square" if user[0].to_i != 0
          friends_with.push({
            :id => 0,
            :name => user[1],
            :photo => user[0],
          })
        end
        
      end
    end
    
    if rtype == 'home_cooked'
      review_dish = HomeCook.find_by_id(dish_id) 
    elsif rtype == 'delivery'
      review_dish = DishDelivery.find_by_id(dish_id)
      restaurant = review_dish.delivery
    else
      review_dish = Dish.find_by_id(dish_id) 
      restaurant = Restaurant.find_by_id(restaurant_id)
    end
    
    favourite = Favourite.find_by_user_id_and_dish_id(user_id, dish_id) ? 1 : 0
    
    data = {
      :review_id => id,
      :created_at => created_at.to_time.to_i,
      :text => text,
      :dish_id => dish_id,
      :dish_name => review_dish.name,
      :dish_votes => review_dish.votes,
      :restaurant_id => restaurant ? restaurant.id : 0,  
      :restaurant_address => restaurant ? "#{restaurant.address}#{restaurant.city ? ', ' + restaurant.city : ''}" : '',    
      :restaurant_name => restaurant ? restaurant.name : '',
      :user_id => user.id,
      :user_name => user.name,
      :user_photo => user.user_photo,
      :likes => count_likes,
      :comments => count_comments,
      :review_rating => rating,
      :dish_rating => review_dish.rating,
      :image_sd => photo.iphone.url != '/images/noimage.jpg' ? photo.iphone.url : '' ,
      :image_hd => photo.iphone_retina.url != '/images/noimage.jpg' ? photo.iphone_retina.url : '',
      :liked => user_id && Like.find_by_user_id_and_review_id(user_id, id) ? 1 : 0,
      :favourite => favourite,
      :self_review => 0,
      :rtype => rtype,
      :friends => friends_with
    }
  end
  
  def photo_iphone
    dish.photo.iphone.url
  end
  
  def self.review_exist?(user_id, dish_id)
    where('user_id = ? && dish_id = ? && DATE(created_at) > CURDATE() - INTERVAL 1 DAY', user_id, dish_id).first
  end  
  
  def self.save_review(user_review)
    rating = user_review[:rating].to_f
    
    if rating > 0
    
      if user_review[:rtype] == 'home_cooked'
        dish = HomeCook.find(user_review[:dish_id])
      elsif user_review[:rtype] == 'delivery'
        dish = DishDelivery.find(user_review[:dish_id])
        restaurant = Delivery.find_by_id(user_review[:restaurant_id])
      else
        dish = Dish.find_by_id(user_review[:dish_id])      
        restaurant = Restaurant.find_by_id(user_review[:restaurant_id])
        network = Network.find_by_id(restaurant.network_id)
      end
  
      if user_review[:photo].blank? && review = review_exist?(user_review[:user_id], user_review[:dish_id])
        
        r = review
        dish.rating = dish.votes == 1?0 : (dish.rating * dish.votes - review.rating) / (dish.votes - 1)
        dish.rating = (dish.rating * (dish.votes - 1) + rating) / dish.votes
        dish.save
        
        if user_review[:rtype] != 'home_cooked'
          if restaurant
            restaurant.rating = restaurant.votes == 1?0 : (restaurant.rating * restaurant.votes - review.rating) / (restaurant.votes - 1)
            restaurant.rating = (restaurant.rating * (restaurant.votes - 1) + rating) / restaurant.votes
            restaurant.save
          end
          if user_review[:rtype] != 'delivery'
            network.rating = network.votes == 1?0 : (network.rating * network.votes - review.rating) / (network.votes - 1)
            network.rating = (network.rating * (network.votes - 1) + rating) / network.votes
            network.save            
            review.lat = restaurant.lat
            review.lng = restaurant.lon
          end
        end
          
        review.rating = rating
        review.comment = user_review[:comment] unless user_review[:comment].blank?
        review.save        
        
      else
        
        r = create(user_review)  
        dish.rating = (dish.rating * dish.votes + rating) / (dish.votes + 1)
        dish.votes += 1
        dish.save
        
        if user_review[:rtype] != 'home_cooked'
          if restaurant
            restaurant.rating = (restaurant.rating * restaurant.votes + rating) / (restaurant.votes + 1)
            restaurant.votes += 1
            restaurant.save
            user_review[:lat] = restaurant.lat
            user_review[:lng] = restaurant.lon
          end
          if user_review[:rtype] != 'delivery'
            network.rating = (network.rating * network.votes + rating) / (network.votes + 1)
            network.votes += 1
            network.save
          end
        end
        status = 'created'
        
      end
    
      if top_uid = (Review.where('dish_id = ?', dish.id).group('user_id').count).max[0]
        if dish.top_user_id != top_uid
          dish.top_user_id = top_uid
          dish.save
          
          system "rake facebook:expert REVIEW_ID='#{r.id}' &"
          system "rake twitter:expert REVIEW_ID='#{r.id}' &"
        end
      end
    
      if restaurant
        if top_uid = (Review.where('restaurant_id = ?', restaurant.id).group('user_id').count).max[0]
          if restaurant.top_user_id != top_uid
            system "rake facebook:expert REVIEW_ID='#{r.id}' &"
            system "rake twitter:expert REVIEW_ID='#{r.id}' &"
          end
          restaurant.top_user_id = top_uid
          restaurant.save
        end
      end
      r
    end
  end 

end
