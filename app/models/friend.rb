class Friend < ActiveRecord::Base
  validates :user_id, :uniqueness => {:scope => [:friend_id, :provider]}
end
