# encoding: utf-8
namespace :twitter do
  
  task :like => :environment do
    like_id = ENV["LIKE_ID"]
    
    if l = Like.find_by_id(like_id)
      r = Review.find_by_id(l.review_id) 
      u = User.find_by_id(l.user_id)    
      
      if r && u
        if !u.oauth_token_secret.blank? && !u.oauth_token.blank? && u.user_preferences.share_my_like_to_twitter == true
          client = Twitter::Client.new(:oauth_token => u.oauth_token, :oauth_token_secret => u.oauth_token_secret)
          
          caption = "liked #{r.user.name.join(' ')[0]}'s dish-in in #{r.dish.name}@#{r.restaurant.name} http://test.dish.fm/reviews/#{r.id}"
          client.update(caption)
        end
      end
      
    end
  end
  
  task :comment => :environment do
    comment_id = ENV["COMMENT_ID"]
    
    if c = Comment.find_by_id(comment_id)
      r = Review.find_by_id(c.review_id) 
      u = User.find_by_id(c.user_id)    
      
      if r && u
        if !u.oauth_token_secret.blank? && !u.oauth_token.blank? && u.user_preferences.share_my_comments_to_twitter == true
          client = Twitter::Client.new(:oauth_token => u.oauth_token, :oauth_token_secret => u.oauth_token_secret)
                    
          caption = "commented on #{r.user.name.join(' ')[0]}'s dish-in in #{r.dish.name}@#{r.restaurant.name} \"#{c.text}\" http://test.dish.fm/reviews/#{r.id}"
          client.update(caption)
          
        end
      end
      
    end
  end
  
  task :expert => :environment do
    review_id = ENV["REVIEW_ID"]
    if rw = Review.find_by_id(review_id)
      
      d = Dish.find_by_id(rw.dish_id)
      r = Restaurant.find_by_id(rw.restaurant_id)
      u = User.find_by_id(rw.user_id) 
      
      if (r || d) && u
        if !u.oauth_token_secret.blank? && !u.oauth_token.blank? && u.user_preferences.share_my_top_expert_to_twitter == true
          client = Twitter::Client.new(:oauth_token => u.oauth_token, :oauth_token_secret => u.oauth_token_secret)
          
          if d.top_user_id == u.id
            caption = "became an expert on #{d.name}@#{r.name}"
          elsif r.top_user_id == u.id
            caption = "became an expert on #{r.name}"
          end
          client.update(caption)
          
        end
      end
      
    end
  end
  
  task :dishin => :environment do
    review_id = ENV["REVIEW_ID"]
    
    if r = Review.find_by_id(review_id)  
      if u = User.find_by_id(r.user_id)
        
        if !u.oauth_token_secret.blank? && !u.oauth_token.blank?
          client = Twitter::Client.new(:oauth_token => u.oauth_token, :oauth_token_secret => u.oauth_token_secret)

          if r.text.blank?
            r.text = case r.rating
              when 0..2.99 then "Survived"
              when 3..3.99 then "Ate"
              when 4..5 then "Enjoyed"
            end
            dish_text = "#{r.text}"
          else
            dish_text = "#{r.text} -"
          end
          
          if r.rtype == 'home_cooked'
            place = "#{r.home_cook.name} (home-cooked)"
          elsif r.rtype == 'delivery'
            place = "#{r.dish_delivery.name} @ #{r.delivery.name}"
          else
            place = "#{r.dish.name} @ #{r.network.name}"
          end
          
          friends = "with #{r.friends.split(',').count} friend(s)" if r.friends
          caption = "#{dish_text} #{place} #{friends}"[0,140] + "http://dish.fm/reviews/#{r.id}"
          client.update(caption)
        end
        
      end
    end
    
  end
end