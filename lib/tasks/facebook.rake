# encoding: utf-8
namespace :facebook do
  
  $domain = 'http://test.dish.fm/'
  
  task :like => :environment do    
    if l = Like.find_by_id(ENV["LIKE_ID"])
      
      r = Review.find_by_id(l.review_id) 
      u = User.find_by_id(l.user_id)
      
      if u.id != r.user_id
        name = "#{r.user.name.split(' ')[0]}'s"
      else
        name = 'his own'
      end    
      
      if r && u
        if !u.fb_access_token.blank? && u.user_preference.share_my_like_to_facebook == true
          graph = Koala::Facebook::API.new(u.fb_access_token)
          graph.put_connections('me', "dish_fm:Like", :review => "#{$domain}reviews/#{r.id}" )
          
          if r.facebook_share_id.blank?
            graph.put_object("me", "feed", :message => "liked #{name} dish-in in #{r.dish.name}@#{r.restaurant.name} #{$domain}reviews/#{r.id}")
          else
            graph.put_object(r.facebook_share_id, 'likes')
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
      
      if u.id != r.user_id
        name = "#{r.user.name.split(' ')[0]}'s"
      else
        name = 'his own'
      end    
      
      if r && u
        if !u.fb_access_token.blank? && u.user_preference.share_my_comments_to_facebook == true
          graph = Koala::Facebook::API.new(u.fb_access_token)
          graph.put_connections('me', "dish_fm:Comment", :review => "#{$domain}reviews/#{r.id}" )
          
          if r.facebook_share_id.blank?
            graph.put_object("me", "feed", :message => "commented on #{name} dish-in in #{r.dish.name}@#{r.restaurant.name} \"#{c.text}\" #{$domain}reviews/#{r.id}")
          else
            graph.put_object(r.facebook_share_id, 'comments', :message => c.text )
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
                    
          graph.put_connections('me', action, :dish => "#{$domain}dishes/#{d.id}") if d.top_user_id == u.id
          graph.put_connections('me', action, :restaurant => "#{$domain}restaurants/#{r.id}") if r.top_user_id == u.id
          
          # graph.put_object("me", "feed", :message => "became an expert on #{d.name}@#{r.name}")
          # graph.put_object("me", "feed", :message => "became an expert on #{r.name}")
        end
      end
      
    end
  end
  
  task :dishin => :environment do    

    if r = Review.find_by_id(ENV["REVIEW_ID"])  
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

          caption = "#{dish_text} #{place} #{$domain}reviews/#{r.id}"
          albuminfo = graph.put_object('me','albums', :name => 'Dish.fm Photos') if albuminfo["id"].blank?

          if picture = graph.put_picture("#{$domain}#{r.photo.iphone_retina.url}", {:caption => caption}, albuminfo["id"])
            graph.put_connections('me', "dish_fm:Post", :review => "#{$domain}reviews/#{r.id}")
            
            review = Review.find_by_id(r.id) 
            review.facebook_share_id = picture['id']
            review.save
            
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