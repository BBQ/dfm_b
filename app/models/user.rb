class User < ActiveRecord::Base
  
  # attr_accessible :facebook_id, :name, :email, :password, :password_confirmation, :authentications_attributes
  # authenticates_with_sorcery! do |config|
  #   config.authentications_class = Authentication
  # end
  
  attr_accessor :password, :password_confirmation
  
  has_many :authentications, :dependent => :destroy
  has_one :user_preference, :dependent => :destroy
  # accepts_nested_attributes_for :authentications

  # validates_confirmation_of :password
  # validates_presence_of :password, :on => :create
  # validates_presence_of :email
  validates_uniqueness_of :email, :allow_nil => true, :allow_blank => true
  
  has_many :reviews
  has_many :comments
  has_many :likes
  has_many :favourites
  
  mount_uploader :photo, ImageUploader
  
  def self.link_push_token(push_token, user_id)
    if push_token_found = APN::Device.find_by_token(push_token)
      if push_token_found.user_id == 0
        push_token_found.update_attributes(:user_id => user_id)
      elsif push_token_found.user_id != user_id
        APN::Device.create({:token => push_token, :user_id => user_id})
      end
    else
      APN::Device.create({:token => push_token, :user_id => user_id})
    end
  end
  
  
  def favourite_dishes(user_id)
    dishes_array = []    
    favourite_dish_ids = []
    favourite_dish_delivery_ids = []
    favourite_home_cook_ids = []
    
    Favourite.where(:user_id => user_id).each do |f|
      if !f.dish_id.nil?
        favourite_dish_ids.push(f.dish_id)
      elsif !f.home_cook_id?
        favourite_home_cook_ids.push(f.home_cook_id)
      elsif !f.dish_delivery_id?
        favourite_dish_delivery_ids.push(f.dish_delivery_id)
      end
    end

    dishes_array |= Dish.favourite(favourite_dish_ids.join(',')) if favourite_dish_ids.any?
    dishes_array |= DishDelivery.favourite(favourite_dish_delivery_ids.join(',')) if favourite_home_cook_ids.any?
    dishes_array |= HomeCook.favourite(favourite_home_cook_ids.join(',')) if favourite_dish_delivery_ids.any?
    
    dishes_array = dishes_array.sort_by { |k| k[:created_at] }.reverse if dishes_array.any?
  end
  
  def dish_expert(current_user_id)
    dishes_array = []    
    
    dishes_array |= Dish.expert(id, current_user_id)
    dishes_array |= DishDelivery.expert(id, current_user_id)
    dishes_array |= HomeCook.expert(id, current_user_id)
    
    dishes_array = dishes_array.sort_by { |k| k[:created_at] }.reverse if dishes_array.any?
  end
  
  
  def self.migrate(old_user, new_user)

    Review.where(:user_id => old_user.id).update_all(:user_id => new_user.id)
  
    likes = Like.where(:user_id => old_user.id)
    
    ids = likes.select(:review_id).where(:user_id => new_user.id).collect{|x| x.review_id}      
    likes = likes.where("review_id NOT IN (#{ids.join(',')})") if ids.any?
    
    likes.update_all(:user_id => new_user.id)
    Like.destroy_all(:user_id => old_user.id)
    
    Comment.where(:user_id => old_user.id).update_all(:user_id => new_user.id)
        
    Dish.where(:top_user_id => old_user.id).update_all(:top_user_id => new_user.id)
    Restaurant.where(:top_user_id => old_user.id).update_all(:top_user_id => new_user.id)
        
    following = Follower.where("user_id = ? AND follow_user_id != ?", old_user.id, new_user.id)
    
    ids = Follower.select(:follow_user_id).where(:user_id => new_user.id).collect{|x| x.follow_user_id}      
    following = following.where("follow_user_id NOT IN (#{ids.join(',')})") if ids.any?
    
    following.update_all(:user_id => new_user.id)
    Follower.destroy_all(:user_id => old_user.id)
    
    followers = Follower.where("follow_user_id = ? AND user_id != ?", old_user.id, new_user.id)

    ids = Follower.select(:user_id).where(:follow_user_id => new_user.id).collect{|x| x.user_id} 
    followers = followers.where("user_id NOT IN (#{ids.join(',')})") if ids.any?
    
    followers.update_all(:follow_user_id => new_user.id)
    Follower.destroy_all(:follow_user_id => old_user.id)
    
    APN::Notification.where(:user_id_from => old_user.id).update_all(:user_id_from => new_user.id)
    APN::Notification.where(:user_id_to => old_user.id).update_all(:user_id_to => new_user.id)
    
    APN::Device.where(:user_id => new_user.id).each do |d|
      if old = APN::Device.find_by_user_id_and_token(old_user.id, d.token)
        old.destroy
      end
    end
    APN::Device.where("user_id = ?", old_user.id).update_all(:user_id => new_user.id)
    
    Session.destroy(:user_id => old_user.id)
    old_user.destroy  
  end
  
  def self.put_friends(fb_f = nil, tw_f = nil)
    friends = []
    
    if fb_f
      fb_f.split(',').each do |f|
        
        if user = User.find_by_facebook_id(f)
          friends.push(user.id)
        else
          rest = Koala::Facebook::GraphAPI.new
          friends.push("#{f}@@@#{rest.get_object(f)['name']}")
        end
        
      end
    end
    
    if tw_f
      tw_f.split(',').each do |f|
        
        if user = User.find_by_twitter_id(f) 
          friends.push(user.id)
        else
          friends.push("#{Twitter.user(f).profile_image_url}@@@#{Twitter.user(f).name}")
        end
        
      end
    end
    friends.join(',')
  end
  
  def user_photo
    domain = 'http://dish.fm'
    if facebook_id
      ph = "http://graph.facebook.com/#{facebook_id}/picture?type=large" unless facebook_id.blank?
    elsif photo.thumb.url != '/images/noimage.jpg'
      ph = "#{domain}#{photo.thumb.url}"
    else
      ph = "#{domain}/images/avatar@2x.png"
    end
    ph ||= ""
  end
  
  def self.get_user_by_fb_token(access_token) # Под снос! 
    begin
      rest = Koala::Facebook::GraphAndRestAPI.new(access_token) # pre-1.2beta
      result = rest.get_object("me")

      if user = User.find_by_facebook_id(result["id"])
        id = user.id
      elsif result["email"] 
        
        id = User.create({
          :email => result["email"] , 
          :name => result["name"], 
          :gender => result["gender"],
          :current_city => result["location"]["name"],
          :facebook_id => result["id"]
        }).id
        
        Authentication.create({
          :user_id => id,
          :provider => 'facebook',
          :uid => result["id"], 
        })
        User.new.get_user_fb_friends(access_token)        
      end
    rescue
      nil
    end
    id
  end
  
  def self.authenticate_by_email_password(email, password, name = nil)
    
    require 'digest/md5'
    md5 = Digest::MD5
    
    if user = find_by_email(email)
      if user.salt
        if user.crypted_password == md5.hexdigest(password + user.salt) 
          token = Session.get_token(user)
        else
         res = {:description => 'Email or password incorrect'}
        end
      else
        res = {:description => 'Email already registered'}
      end
    elsif !name.blank?
      require "base64"
      salt = Base64.encode64(password)      
      if user = User.create(:email => email, :crypted_password => md5.hexdigest(password + salt), :salt => salt, :name => name.strip)
        UserPreference.create({:user_id => user.id})
        token = Session.get_token(user)
        follow_dishfm_user(user.id)
      end
    else
      res = {:description => 'Empty name is not allowed'}
    end
    
    unless token.nil?
      res = {:name => user.name, :fb_access_token => user.fb_access_token, :fb_valid_to => user.fb_valid_to.to_i, :oauth_token => user.oauth_token, :oauth_token_secret => user.oauth_token_secret, :token => token, :user_id => user.id, :photo => user.user_photo, :facebook_id => user.facebook_id ||= 0, :twitter_id => user.twitter_id ||= 0}
    end
    
    res
  end
  
  def update_password(password)
    require "base64"
    salt = Base64.encode64(password)
    
    require 'digest/md5'
    md5 = Digest::MD5
    
    self.crypted_password = md5.hexdigest(password + salt)
    self.salt = salt
    self.save
  end
  
  def self.follow_dishfm_user(user_id)
    dish_fm_user_id = 540
    Follower.create(:user_id => user_id, :follow_user_id => dish_fm_user_id)
    Follower.create(:user_id => dish_fm_user_id, :follow_user_id => user_id)
    Notification.send(dish_fm_user_id, 'following', user_id)
  end
  
  def self.authenticate_by_twitter(oauth_token, oauth_token_secret, email = nil)
    begin
      client = Twitter::Client.new(:oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret)
      if user = User.find_by_twitter_id(client.user.id)
        user.oauth_token = oauth_token
        user.oauth_token_secret = oauth_token_secret
        user.save
      else
        user = create_user_from_twitter(client, email)
      end
      token = Session.get_token(user)
    rescue
      nil
    end
    {:name => user.name, :fb_access_token =>user.fb_access_token, :fb_valid_to => user.fb_valid_to.to_i, :oauth_token => user.oauth_token, :oauth_token_secret => user.oauth_token_secret, :token => token, :user_id => user.id, :photo => user.user_photo, :facebook_id => user.facebook_id ||= 0, :twitter_id => user.twitter_id ||= 0} unless token.nil?
  end
  
  def self.create_user_from_twitter(client, email = nil)
    user = User.create({
      :name => client.user.name,
      :email => email,  
      :twitter_id => client.user.id,
      :remote_photo_url => client.profile_image,
      :oauth_token => client.oauth_token,
      :oauth_token_secret => client.oauth_token_secret
    })
    UserPreference.create({:user_id => user.id})
    
    get_twitter_friends(client, user)
    get_twitter_followers(client, user)
    follow_dishfm_user(user.id)
    
    user
  end
  
  def self.get_twitter_friends(client, user, next_cursor = -1)
    friends = client.friend_ids(:next_cursor => next_cursor)
    follow_tw_users(friends, user)
    get_twitter_friends(client, user, friends.next_cursor) if friends.next_cursor > 0
  end
  
  def self.get_twitter_followers(client, user, next_cursor = -1)
    followers = client.follower_ids(:next_cursor => next_cursor)
    follow_tw_users(followers, user)
    get_twitter_followers(client, user, followers.next_cursor) if followers.next_cursor > 0
  end
  
  def self.follow_tw_users(users, user)
    users.ids.each do |tw_id|
      if found_user = User.find_by_twitter_id(tw_id)
        if Follower.create({:user_id => user.id, :follow_user_id => found_user.id})
          Notification.send(user.id, 'following', found_user.id)
        end
      end
    end
  end
  
  def self.authenticate_by_facebook(access_token, fb_valid_to = nil)
      
      rest = Koala::Facebook::GraphAndRestAPI.new(access_token) # pre-1.2beta
      result = rest.get_object("me")

      if user = User.find_by_facebook_id(result["id"])
        token = Session.get_token(user)
        user.fb_access_token = access_token
        user.fb_valid_to =  Time.at(fb_valid_to.to_i) if fb_valid_to
        user.save
      elsif result["email"] 
        user = create_user_from_facebook(rest,fb_valid_to)
        token = Session.get_token(user)        
      end
      {:name => user.name, :fb_access_token => user.fb_access_token, :fb_valid_to => user.fb_valid_to.to_i,  :oauth_token => user.oauth_token, :oauth_token_secret => user.oauth_token_secret, :token => token, :user_id => user.id, :photo => user.user_photo, :facebook_id => user.facebook_id ||= 0, :twitter_id => user.twitter_id ||= 0} unless token.nil?
  end
  
  def self.create_user_from_facebook(rest, fb_valid_to = nil)
    auth_result = rest.get_object("me")
    data = {
      :email => auth_result["email"] , 
      :name => auth_result["name"], 
      :gender => auth_result["gender"],
      :current_city => auth_result["location"] ? auth_result["location"]["name"] : '',
      :facebook_id => auth_result["id"],
      :fb_access_token => rest.access_token,
      :fb_valid_to => Time.at(fb_valid_to.to_i)
    }
    
    if user = User.create(data)
      
      Authentication.create({
        :user_id => user.id,
        :provider => 'facebook',
        :uid => auth_result["id"], 
      })  
      
      UserPreference.create(:user_id => user.id)
      follow_dishfm_user(user.id)
      
      rest.get_connections("me", "friends").each do |f|
        if user_friend = User.find_by_facebook_id(f['id'])
          if Follower.create({:user_id => user.id, :follow_user_id => user_friend.id})
            Notification.send(user.id, 'following', user_friend.id)
          end
        end
      end
      
      user
    end
  end
    
  def get_user_fb_token(code)
    key = Dishfm::Application.config.sorcery.facebook.key
    secret = Dishfm::Application.config.sorcery.facebook.secret
    callback_url = Dishfm::Application.config.sorcery.facebook.callback_url
    
    oauth = Koala::Facebook::OAuth.new(key, secret, callback_url)
    begin
      access_token = oauth.get_access_token(code)
    rescue
      nil
    end
  end
  
  def self.get_user_fb_friends(code_or_access_token)
    if code_or_access_token
      if User.new.get_user_fb_token(code_or_access_token)
        access_token = User.new.get_user_fb_token(code_or_access_token)
      else
        access_token = code_or_access_token         
      end
    end
    system "rake get_facebook_friends ACCESS_TOKEN='#{access_token}' &" if access_token
  end
  
  def self.get_user_tw_friends(user_id)
    system "rake get_twitter_friends USER=#{user_id} &" if user_id
  end
  

  
end