# encoding: utf-8
task :get_twitter_friends => :environment do
  if friends = Twitter.follower_ids(ENV["USER"].to_i)
    friends.ids.each do |id|
      data = {
        :provider => 'twitter',
        :user_id => ENV["USER"],
        :friend_id => id,
      }
      Friend.create(data)
    end
  end
end