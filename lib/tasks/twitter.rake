# encoding: utf-8
namespace :twitter do
  
  task :like => :environment do
    
  end
  
  task :comment => :environment do
    
  end
  
  task :expert => :environment do
    
  end
  
  task :dishin => :environment do
    review_id = ENV["REVIEW_ID"]
    
    if r = Review.find_by_id(review_id)  
      if u = User.find_by_id(r.user_id)
        
        if !u.oauth_token_secret.blank? && !oauth_token.blank?
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