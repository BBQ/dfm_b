class Follower < ActiveRecord::Base
  validates :user_id, :uniqueness => {:scope => :follow_user_id}
end
