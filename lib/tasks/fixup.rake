# encoding: utf-8
namespace :fix do
  
  desc "Update no_rate_order for Dishes"
  task :dish_norate => :environment do
    i = 1
    Dish.where('rating = 0').order("fsq_checkins_count DESC, photo DESC, description DESC, updated_at DESC, price DESC").each do |d|
      d.no_rate_order = i
      p d.id
      d.save
      i += 1
    end
  end
  
  desc "Update Ratings for Dishes"
  task :dish_rating => :environment do
      Review.select(:dish_id).group(:dish_id).each do |rw|
        if dish = Dish.find_by_id(rw.dish_id)
          p "#{dish.id} #{dish.name}"
          summ = 0
          dish.reviews.each {|dr| summ += dr.rating}

          dish.votes = dish.reviews.count
          dish.rating = summ/dish.votes

          dish.save
        end
      end
  end
  
  desc "Update Foursquare User Checkins for Dishes by setting max(Foursquare User Checkins) from network resataurant"
  task :dish_fsq => :environment do
    Dish.all.each do |d|
      p d.name
      c = d.network.restaurants.order('fsq_checkins_count DESC').limit(1)
      if r = c[0]
        d.fsq_checkins_count = r.fsq_checkins_count ||= 0
        d.save
      end
    end
    
    Network.all.each do |n|
      c = n.restaurants.order('fsq_checkins_count DESC').limit(1)
      if r = c[0]
        n.fsq_checkins_count = r.fsq_checkins_count ||= 0
        n.save
      end
    end
  end

  desc "Update Restaurants set restaurants_count"
  task :rest_count => :environment do
    Restaurant.all.each do |r|
      r.count_dishes = r.network.dishes.count ||= 0
      r.save
    end
  end  
  

  desc "Update Dishes with information from networks"
  task :upd_dishes => :environment do
    Network.where('`fsq_users_count` IS NOT NULL OR `votes` > 0 OR `rating` > 0').each do |n|
      n.dishes.each do |d|
        d.network_fsq_users_count = n.fsq_users_count
        d.network_votes = n.votes
        d.network_rating = n.rating
        d.save
        p d.name
      end
    end
  end
  
  desc "Update Foursquare User Checkins for Networks by setting max(Foursquare User Checkins) from network resataurant"
  task :net_fsq => :environment do
    Network.all.each do |n|
      c = n.restaurants.order('fsq_checkins_count DESC').limit(1)
      if r = c[0]
        n.fsq_checkins_count = r.fsq_checkins_count ||= 0
        n.save
      end
    end
  end
  
  task :set_zero => :environment do
    Restaurant.all.each do |r|
      # fix wifi
      if r.wifi.to_i == '1' || r.wifi == 'true' || r.wifi == 'да'
        r.wifi = 1
      else
        r.wifi = 0
      end 
      r.save
    end
    puts 'done!'
  end
  
  task :likes => :environment do
    Review.all.each do |r|
      r.count_likes = r.likes.count
      r.save
    end
  end
  
  task :phone => :environment do
    Restaurant.all.each do |r|
      unless r.phone.nil?
        p_arr = []
        r.phone.split(/[,;]/).each do  |p|
          phone = p.gsub('.0','')
          phone = phone.gsub(/\D/,'').to_s
          
          if phone && phone.length <= 11
            
            dp = 0
            if phone.length == 11
              phone = "+7(#{phone[1,3]})-#{phone[4,3]}-#{phone[7,2]}-#{phone[9,2]}" if phone[0] == '7'
              phone = "+7(#{phone[1,3]})-#{phone[4,3]}-#{phone[7,2]}-#{phone[9,2]}" if phone[0] == '8'
              phone = "+7(495)-#{phone[0,3]}-#{phone[3,2]}-#{phone[5,2]} доб.(#{phone[7,4]})" if !phone['2218381'].nil? # coffeehouse.ru
              dp = 1
            elsif phone.length == 10
              phone = "+7(#{phone[0,3]})-#{phone[3,3]}-#{phone[6,2]}-#{phone[8,2]}"
              dp = 1
            elsif phone.length == 7
              phone = "+7(495)-#{phone[0,3]}-#{phone[3,2]}-#{phone[5,2]}"
              dp = 1
            elsif !p['--- {}'].nil?
              phone = nil
              dp = 1
            end
            
            if dp == 1 
              p_arr.push(phone)
            elsif count = p_arr.count
              p_arr[count] = "#{p_arr.last} доб.(#{phone})"
            end
            
          else
            p "fix me :#{r.id} - #{p}"
          end
        end
        r.phone = p_arr.join('; ')
        r.save
        p "#{r.id} #{r.phone}"
      end
    end
  end
  
  
end