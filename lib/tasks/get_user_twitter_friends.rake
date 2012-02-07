# encoding: utf-8
task :get_twitter_friends => :environment do
  
  Twitter.follower_ids(ENV["USER"]).each do |friend|
    data = {
      :provider => 'twetter',
      :user_id => ENV["USER"],
      :friend_id => friend,
    }
    Friend.create(data)
  end
  
end