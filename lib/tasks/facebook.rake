# encoding: utf-8
namespace :facebook do
  
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

          picture = graph.put_picture("http://test.dish.fm/#{r.photo.iphone_retina.url}", {:caption => caption}, albuminfo["id"])

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
          graph.put_object(picture['id'],'tags', :tags => "[#{tags.join(',')}]")
        end
      end
    end
    
  end
end