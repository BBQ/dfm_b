# encoding: utf-8
task :get_facebook_friends => :environment do

  rest = Koala::Facebook::GraphAPI.new(ENV["ACCESS_TOKEN"])
  user = rest.get_object("me")
  friends = rest.get_connections("me", "friends")
  
  friends.each do |friend|
    fb_friend = Hash.new
    fb_friend[:provider] = 'facebook'
    fb_friend[:user_id] = user["id"]
    fb_friend[:friend_id] = friend['id']
    fb_friend[:friend_name] = friend['name']
    Friend.create(fb_friend)
  end
  
end