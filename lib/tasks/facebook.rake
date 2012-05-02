# encoding: utf-8
namespace :facebook do
  
  task :like => :environment do
    like_id = ENV["LIKE_ID"]
    
    if l = Like.find_by_id(like_id)
      r = Review.find_by_id(l.review_id) 
      u = User.find_by_id(l.user_id)    
      
      if r && u
        if !u.fb_access_token.blank? && u.user_preference.share_my_like_to_facebook == true
          graph = Koala::Facebook::API.new(u.fb_access_token)
          graph.put_connections('me', "dish_fm:review", :review => "http://dish.fm/reviews/#{r.id}" )
          
          if r.facebook_share_id.blank?
            graph.put_object("me", "feed", :message => "liked #{r.user.name.join(' ')[0]}'s dish-in in #{r.dish.name}@#{r.restaurant.name} http://test.dish.fm/reviews/#{r.id}")
          else
            graph.put_object(picture['id'], 'likes')
          end
          
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
        if !u.fb_access_token.blank? && u.user_preference.share_my_comments_to_facebook == true
          graph = Koala::Facebook::API.new(u.fb_access_token)
          graph.put_connections('me', "dish_fm:Comment", :review => "http://dish.fm/reviews/#{r.id}" )
          
          if r.facebook_share_id.blank?
            graph.put_object("me", "feed", :message => "commented on #{r.user.name.join(' ')[0]}'s dish-in in #{r.dish.name}@#{r.restaurant.name} \"#{c.text}\" http://test.dish.fm/reviews/#{r.id}")
          else
            graph.put_object(picture['id'],'comments', :message => c.text )
          end
          
        end
      end
      
    end
  end
  
  task :expert => :environment do
    if rw = Review.find_by_id(ENV["REVIEW_ID"])
      
      d = Dish.find_by_id(rw.dish_id)
      r = Restaurant.find_by_id(rw.restaurant_id)
      u = User.find_by_id(rw.user_id) 
      
      if (r || d) && u
        if !u.fb_access_token.blank? && u.user_preference.share_my_top_expert_to_facebook == true

          graph = Koala::Facebook::API.new(u.fb_access_token)
          action = "dish_fm:Become_An_Expert"
                    
          graph.put_connections('me', action, :dish => "http://test.dish.fm/dishes/#{d.id}") if d.top_user_id == u.id
          graph.put_connections('me', action, :restaurant => "http://test.dish.fm/restaurants/#{r.id}") if r.top_user_id == u.id
          
          # graph.put_object("me", "feed", :message => "became an expert on #{d.name}@#{r.name}")
          # graph.put_object("me", "feed", :message => "became an expert on #{r.name}")
        end
      end
      
    end
  end
  
  task :dishin => :environment do    
    review_id = ENV["REVIEW_ID"]
    
    if r = Review.find_by_id(review_id)  
      if u = User.find_by_id(r.user_id)
        
        unless u.fb_access_token.blank? 
          graph = Koala::Facebook::API.new(u.fb_access_token)

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
          
          albuminfo = {}
          graph.get_connections('me', 'albums').each do |alb|
            if alb['name'] == 'Dish.fm Photos'
              albuminfo = {'id' => alb['id']}
              break
            end
          end

          caption = "#{dish_text} #{place} http://dish.fm/reviews/#{r.id}"
          albuminfo = graph.put_object('me','albums', :name => 'Dish.fm Photos') if albuminfo["id"].blank?

          if picture = graph.put_picture("http://test.dish.fm/#{r.photo.iphone_retina.url}", {:caption => caption}, albuminfo["id"])
            
            rev = Review.find_by_id(review_id) 
            rev.facebook_share_id = picture['id']
            rev.save
            
            tags = []
            if r.friends
              r.friends.split(',').each do |u|
                
                if user = User.find_by_id(u)
                  tags.push("{\"tag_uid\":\"#{user.facebook_id}\"}")
                elsif user = u.split('@@@')
                  tags.push("{\"tag_uid\":\"#{user[0]}\"}")
                end
                
              end
            end
            
            graph.put_object(picture['id'],'tags', :tags => "[#{tags.join(',')}]") if tags.count > 0
          end
          
        end

      end
    end
    
  end
end