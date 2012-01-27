# encoding: utf-8
namespace :fix do

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
  task :net_fsq_uc => :environment do
    Network.all.each do |n|
      c = n.restaurants.order('fsq_users_count DESC').limit(1)
      if r = c[0]
        n.fsq_users_count = r.fsq_users_count
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