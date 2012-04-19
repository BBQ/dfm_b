class Session < ActiveRecord::Base
  
  require 'digest/md5'  
    
  def self.get_token(user)
    md5 = Digest::MD5
    
    if token = Session.find_by_user_id(user.id)
      real_token = "#{md5.hexdigest(token.salt)}#{md5.hexdigest(token.session_token)}"
    else
      session_token = md5.hexdigest(user.created_at.to_s).to_s
      salt = (0...4).map{ ('A'..'Z').to_a[rand(26)]}.join
      
      Session.create({:user_id => user.id, :session_token => session_token, :salt => salt})    
      real_token = "#{md5.hexdigest(salt)}#{md5.hexdigest(session_token)}"
    end
    
  end
  
  def self.check_token(user_id, token)
    md5 = Digest::MD5
    if s = Session.find_by_user_id(user_id)
      if "#{md5.hexdigest(s.salt)}#{md5.hexdigest(s.session_token)}" == token
        real_token = "#{md5.hexdigest(s.salt)}#{md5.hexdigest(s.session_token)}"
      end
    end
    real_token ||= nil
  end
  
end
