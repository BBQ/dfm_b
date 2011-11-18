class User < ActiveRecord::Base
  
  attr_accessible :facebook_id, :name, :email, :password, :password_confirmation, :authentications_attributes
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
  
  def post_registration(access_token)

  end
  
  def get_user_by_fb_token(access_token)
    begin
      rest = Koala::Facebook::GraphAndRestAPI.new(access_token) # pre-1.2beta
      result = rest.get_object("me")
      if user = User.find_by_facebook_id(result["id"])
        id = user.id
      elsif result["email"] 
        data = {:email => result["email"] , :name => result["name"], :facebook_id => result["id"]}
        id = User.create(data)
        User.new.get_user_fb_friends(access_token)
      end
    rescue
      nil
    end
    id
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
