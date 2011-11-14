class User < ActiveRecord::Base
  
  attr_accessible :email, :password, :password_confirmation, :authentications_attributes
  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end
  
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email
  
  has_many :reviews
  has_many :comments
  
  def post_registration(access_token)

  end
  
  def get_user_by_fb_token(access_token)
    rest = Koala::Facebook::GraphAndRestAPI.new(access_token) # pre-1.2beta
    result = rest.get_object("me")
    User.find_or_create_by_facebook_id(result["id"]).id
  end
  
  def get_user_fb_token(code)
    key = Dishfm::Application.config.sorcery.facebook.key
    secret = Dishfm::Application.config.sorcery.facebook.secret
    callback_url = Dishfm::Application.config.sorcery.facebook.callback_url
    
    oauth = Koala::Facebook::OAuth.new(key, secret, callback_url)
    access_token = oauth.get_access_token(code)
  end
  
  def get_user_fb_friends(code)
    system "rake get_facebook_friends ACCESS_TOKEN='#{User.new.get_user_fb_token(code)}' &"
  end
  

  
end
