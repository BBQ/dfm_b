class User < ActiveRecord::Base
  
  # attr_accessible :facebook_id, :name, :email, :password, :password_confirmation, :authentications_attributes
  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end
  
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  # validates_confirmation_of :password
  # validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email
  
  has_many :reviews
  has_many :comments
  has_many :likes
  
  mount_uploader :photo, ImageUploader
  
  def user_photo
    if photo.blank?
      "http://graph.facebook.com/#{facebook_id || = 0}/picture?type=square"
    else
      "http://test.dish.fm#{photo.p60.url}"
    end
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
  
  def self.authenticate_by_facebook(access_token)
    begin
      
      rest = Koala::Facebook::GraphAndRestAPI.new(access_token) # pre-1.2beta
      result = rest.get_object("me")

      if user = User.find_by_facebook_id(result["id"])
        token = Session.get_token(user)
      elsif result["email"] 
        user = create_user_from_facebook(result)
        token = Session.get_token(user)        
      end
    rescue
      nil
    end
    {:token => token, :user_id => user.id} unless token.nil? 
  end
  
  def self.create_user_from_facebook(auth_result)
    user = User.create({
      :email => auth_result["email"] , 
      :name => auth_result["name"], 
      :gender => auth_result["gender"],
      :current_city => auth_result["location"]["name"],
      :facebook_id => auth_result["id"]
    })
    
    Authentication.create({
      :user_id => id,
      :provider => 'facebook',
      :uid => auth_result["id"], 
    })
    User.new.get_user_fb_friends(access_token)
    user
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
  
  def get_user_fb_friends(code_or_access_token)
    if code_or_access_token
      if User.new.get_user_fb_token(code_or_access_token)
        access_token = User.new.get_user_fb_token(code_or_access_token)
      else
        access_token = code_or_access_token         
      end
    end
    system "rake get_facebook_friends ACCESS_TOKEN='#{access_token}' &" if access_token
  end
  

  
end
