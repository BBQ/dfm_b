# encoding: utf-8
namespace :mi do
  
  task :patch => :environment do
    Dish.select(:network_id).where('name IS NULL').group(:network_id).each do |d1|
      
      p "#{d1.network_id}"
      
      Dish.select(:id).where(:network_id => d1.network_id).each {|dd| dd.destroy}
      r1 = MiRestaurant.find_by_our_network_id(d1.network_id)        
      
      MiDish.where(:restaurant_id => r1.mi_id).each do |d|
         if Dish.select(:id).where("network_id = ? AND name = ?", d1.network_id, d.name).first.blank?   
           types = {
             '1' => 14,
             '10' => 16,
             '11' => 15,
             '13' => 18,
             '14' => 15,
             '16' => 18,
             '17' => 2,
             '18' => 15,
             '2' => 4,
             '20' => 17, 
             '3' => 15,
             '4' => 15,
             '5' => 15,
             '594' => 15,
             '6' => 15,
             '6906' => 2,
             '6907' => 2,
             '6961' => 7,
             '7' => 2,
             '8' => 14,
             '9' => 15
           }

           sub_types = {
             '11' => 13,
             '17' => 28,
             '18' => 21,
             '3' => 46,
             '4' => 7,
             '5' => 11,
             '594' => 4,
             '6' => 19,
             '6907' => 27,
             '9' => 5
           }

           dc_name = d.category_name.downcase.gsub(/^\p{Space}+|\p{Space}+$/, "")
           dish_category_id = DishCategory.find_by_name(dc_name) ? DishCategory.find_by_name(dc_name).id : DishCategory.create(:name => dc_name).id

           dish_data = {
             :name => d.name,
             :remote_photo_url => d.pictures.blank? ? nil : "http://188.93.18.50/menutka/GetImageMedium/#{d.pictures[/"([\d]+)"/, 1]}.jpg",
             :price => d.price,
             :description => d.description['--- {}'].nil? ? d.description : nil,
             :network_id => d1.network_id,

             :dish_category_id => dish_category_id,
             :dish_type_id => types[d.category_id],
             :dish_subtype_id => sub_types[d.category_id],
             :dish_extratype_id => d.vegetarian == 'true' ? 4 : nil,
           }

           Dish.create(dish_data)
           p dish_data[:name]

           dc_chk = ''
           network_chk = ''
           i = 0

           if d.category_name != dc_chk
              i += 1
              if dc = DishCategory.find_by_name(dc_name)
                  if dish_network =  Network.find_by_id(d1.network_id)
                      dish_network.restaurants.each do |r|
                          unless DishCategoryOrder.find_by_dish_category_id_and_restaurant_id(dc.id, r.id)
                              DishCategoryOrder.create({
                                :dish_category_id => dc.id,
                                :network_id => dish_network.id,
                                :restaurant_id => r.id,
                                :order => i
                              })
                            end
                      end
                      i = 0 if d1.network_id != network_chk
                      network_chk = d1.network_id
                  end
              end
              dc_chk = d.category_name
           end

        end
      end
    end
  end
  task :match_rr => :environment do
    
     Dish.group(:network_id).having('COUNT(id) < 10').order(:network_id).each do |d1|
       Dish.where(:network_id => d1.network_id).each do |d2|         
         if rew = Review.find_by_dish_id(d2.id)
           
           r = Restaurant.find_by_id(rew.restaurant_id)
           if m_r = MiRestaurant.where(:our_network_id => rew.network_id).by_distance(r.lat, r.lon).first    
             
             # Match restaurant
             d = 0
             p "Lets take #{r.name}"

             Restaurant.where(:network_id => rew.network_id) do |rd|
               rd.destroy
               d += 1
             end
             p "Deleted: #{d}"
             
             c = 0
             MiRestaurant.where(:our_network_id => rew.network_id).each do |cr|
               restaurant_data = {
                 :name => cr.name.capitalize_first_letter,
                 :address => cr.address,
                 :time => cr.worktime,
                 :phone => cr.telephone,
                 :description => cr.description,
                 :web => cr.site,
                 :lat => cr.latitude,
                 :lon => cr.longitude,
                 :network_id => cr.our_network_id,
                 :wifi => cr.wifi || 0,
                 :station => cr.metro,
                 :source => 'web_mi',
               }
               c += 1
               restaurant = Restaurant.create(restaurant_data)
               RestaurantImage.create(:remote_photo_url => "http://188.93.18.50/menutka/GetImageMedium/#{cr.picture}.jpg", :restaurant_id => restaurant.id) unless cr.picture.blank?
             
               if cr.id = m_r.id
                 Review.where(:dish_id => d2.id).each do |ur|
                   ur.restaurant_id = restaurant.id
                   p "Matched!!!"
                 end
               end
               p "#{cr.id} #{restaurant_data[:name]} : #{restaurant_data[:address]}"
               
               # Add Dishes
               MiDish.where(:restaurant_id => m_r.mi_id).each do |d|
                 if Dish.select(:id).where("network_id = ? AND name = ?", rew.network_id, d.name).first.blank?   
                   types = {
                     '1' => 14,
                     '10' => 16,
                     '11' => 15,
                     '13' => 18,
                     '14' => 15,
                     '16' => 18,
                     '17' => 2,
                     '18' => 15,
                     '2' => 4,
                     '20' => 17, 
                     '3' => 15,
                     '4' => 15,
                     '5' => 15,
                     '594' => 15,
                     '6' => 15,
                     '6906' => 2,
                     '6907' => 2,
                     '6961' => 7,
                     '7' => 2,
                     '8' => 14,
                     '9' => 15
                   }

                   sub_types = {
                     '11' => 13,
                     '17' => 28,
                     '18' => 21,
                     '3' => 46,
                     '4' => 7,
                     '5' => 11,
                     '594' => 4,
                     '6' => 19,
                     '6907' => 27,
                     '9' => 5
                   }

                   dc_name = d.category_name.downcase.gsub(/^\p{Space}+|\p{Space}+$/, "")
                   dish_category_id = DishCategory.find_by_name(dc_name) ? DishCategory.find_by_name(dc_name).id : DishCategory.create(:name => dc_name).id

                   dish_data = {
                     :name => d.name,
                     :remote_photo_url => d.pictures.blank? ? nil : "http://188.93.18.50/menutka/GetImageMedium/#{d.pictures[/"([\d]+)"/, 1]}.jpg",
                     :price => d.price,
                     :description => d.description['--- {}'].nil? ? d.description : nil,
                     :network_id => rew.network_id,

                     :dish_category_id => dish_category_id,
                     :dish_type_id => types[d.category_id],
                     :dish_subtype_id => sub_types[d.category_id],
                     :dish_extratype_id => d.vegetarian == 'true' ? 4 : nil,
                   }

                   Dish.create(dish_data)
                   p dish_data[:name]

                   dc_chk = ''
                   network_chk = ''
                   i = 0

                   if d.category_name != dc_chk
                      i += 1
                      if dc = DishCategory.find_by_name(dc_name)
                          if dish_network =  Network.find_by_id(rew.network_id)
                              dish_network.restaurants.each do |r|
                                  unless DishCategoryOrder.find_by_dish_category_id_and_restaurant_id(dc.id, r.id)
                                      DishCategoryOrder.create({
                                        :dish_category_id => dc.id,
                                        :network_id => dish_network.id,
                                        :restaurant_id => r.id,
                                        :order => i
                                      })
                                    end
                              end
                              i = 0 if rew.network_id != network_chk
                              network_chk = rew.network_id
                          end
                      end
                      dc_chk = d.category_name
                   end

                 end
               end

             end
             
           end
         else
           d2.destroy
         end
       end
     end       
   end
  
  task :match_d => :environment do
    Restaurant.group(:network_id).where("source = 'web_mi'").order(:network_id).each do |n|
      
      if r = MiRestaurant.find_by_our_network_id(n.network_id)
        p "#{r.our_network_id}. #{r.name}"
      else
        n1 = Network.select(:name).find_by_id(n.network_id)
        r = MiRestaurant.find_by_name(n1.name)
        p "#{n.network_id}. #{r.name}"
      end
      
      MiDish.where(:restaurant_id => r.mi_id).each do |d|
        if Dish.select(:id).where("network_id = ? AND name = ?", n.network_id, d.name).first.blank?   
          types = {
            '1' => 14,
            '10' => 16,
            '11' => 15,
            '13' => 18,
            '14' => 15,
            '16' => 18,
            '17' => 2,
            '18' => 15,
            '2' => 4,
            '20' => 17, 
            '3' => 15,
            '4' => 15,
            '5' => 15,
            '594' => 15,
            '6' => 15,
            '6906' => 2,
            '6907' => 2,
            '6961' => 7,
            '7' => 2,
            '8' => 14,
            '9' => 15
          }
      
          sub_types = {
            '11' => 13,
            '17' => 28,
            '18' => 21,
            '3' => 46,
            '4' => 7,
            '5' => 11,
            '594' => 4,
            '6' => 19,
            '6907' => 27,
            '9' => 5
          }
      
          dc_name = d.category_name.downcase.gsub(/^\p{Space}+|\p{Space}+$/, "")
          dish_category_id = DishCategory.find_by_name(dc_name) ? DishCategory.find_by_name(dc_name).id : DishCategory.create(:name => dc_name).id
      
          dish_data = {
            :name => d.name,
            :remote_photo_url => d.pictures.blank? ? nil : "http://188.93.18.50/menutka/GetImageMedium/#{d.pictures[/"([\d]+)"/, 1]}.jpg",
            :price => d.price,
            :description => d.description['--- {}'].nil? ? d.description : nil,
            :network_id => n.network_id,
        
            :dish_category_id => dish_category_id,
            :dish_type_id => types[d.category_id],
            :dish_subtype_id => sub_types[d.category_id],
            :dish_extratype_id => d.vegetarian == 'true' ? 4 : nil,
          }
          
          Dish.create(dish_data)
          p dish_data[:name]
                
          dc_chk = ''
          network_chk = ''
          i = 0

          if d.category_name != dc_chk
             i += 1
             if dc = DishCategory.find_by_name(dc_name)
                 if dish_network =  Network.find_by_id(n.network_id)
                     dish_network.restaurants.each do |r|
                         unless DishCategoryOrder.find_by_dish_category_id_and_restaurant_id(dc.id, r.id)
                             DishCategoryOrder.create({
                               :dish_category_id => dc.id,
                               :network_id => dish_network.id,
                               :restaurant_id => r.id,
                               :order => i
                             })
                           end
                     end
                     i = 0 if n.network_id != network_chk
                     network_chk = n.network_id
                 end
             end
             dc_chk = d.category_name
          end
          
        end
      end
    end
  end
  
  
  task :pic => :environment do
    # MiRestaurant.all.each do |r|
    #   if r.picture
    #     pic = r.picture[/"([\d]+)"/, 1]
    #     r.picture = pic
    #     r.save
    #     p pic
    #   end
    # end  
    
    # MiDish.all.where("pictures IS NOT NULL").each do |d|
    #   pic = d.pictures[/"([\d]+)"/, 1]
    #   d.pictures = pic
    #   d.save
    #   p pic
    # end
  end
  task :import => :environment do
    
    require 'csv'

    directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/'
    log_file_path = File.dirname(__FILE__).sub('/lib/tasks', '') + "/log/import/#{Time.new.strftime("%F-%H_%M_%S")}_excel_export.log"
    file = directory + 'REST-ZS.xlsx'
    parser = Excelx.new(file, false, :ignore)  
    restaurant_chk = String

    1.upto(parser.last_row) do |line|
      if r = MiRestaurant.find_by_id(parser.cell(line,'E').to_i)
        MiRestaurant.where('city = "MSK" AND network_id = ?', r.network_id).each do |n|
          p "#{r.id} - #{r.network_id} - #{parser.cell(line,'F')} - #{n.name} - #{parser.cell(line,'G').to_i}"
          n.our_network_id = parser.cell(line,'G').to_i == 0 ? 999999 : parser.cell(line,'G').to_i
          # n.name = parser.cell(line,'F')
          n.save
        end
      end  
    end
    p 'Done!'  
  end
  
  task :match_rwd => :environment do
    
    Review.group(:network_id).where('id > 444').each do |review|
      if review.network.dishes.count < 15
        p "Start with #{review.id}."
        
        if cr = MiRestaurant.find_by_our_network_id(review.network_id)  
          MiDish.where(:restaurant_id => cr.mi_id).each do |d|
            if Dish.select(:id).where("network_id = ? AND name = ?", review.network_id, d.name).first.blank?   
              types = {
                '1' => 14,
                '10' => 16,
                '11' => 15,
                '13' => 18,
                '14' => 15,
                '16' => 18,
                '17' => 2,
                '18' => 15,
                '2' => 4,
                '20' => 17, 
                '3' => 15,
                '4' => 15,
                '5' => 15,
                '594' => 15,
                '6' => 15,
                '6906' => 2,
                '6907' => 2,
                '6961' => 7,
                '7' => 2,
                '8' => 14,
                '9' => 15
              }

              sub_types = {
                '11' => 13,
                '17' => 28,
                '18' => 21,
                '3' => 46,
                '4' => 7,
                '5' => 11,
                '594' => 4,
                '6' => 19,
                '6907' => 27,
                '9' => 5
              }
          
               dc_name = d.category_name.downcase.gsub(/^\p{Space}+|\p{Space}+$/, "")
               dish_category_id = DishCategory.find_by_name(dc_name) ? DishCategory.find_by_name(dc_name).id : DishCategory.create(:name => dc_name).id

               dish_data = {
                 :name => d.name,
                 :remote_photo_url => d.pictures.blank? ? nil : "http://188.93.18.50/menutka/GetImageMedium/#{d.pictures[/"([\d]+)"/, 1]}.jpg",
                 :price => d.price,
                 :description => d.description['--- {}'].nil? ? d.description : nil,
                 :network_id => review.network_id,

                 :dish_category_id => dish_category_id,
                 :dish_type_id => types[d.category_id],
                 :dish_subtype_id => sub_types[d.category_id],
                 :dish_extratype_id => d.vegetarian == 'true' ? 4 : nil,
               }

               Dish.create(dish_data)
               p dish_data[:name]

               dc_chk = ''
               network_chk = ''
               i = 0

               if d.category_name != dc_chk
                  i += 1
                  if dc = DishCategory.find_by_name(dc_name)
                      if dish_network =  Network.find_by_id(review.network_id)
                          dish_network.restaurants.each do |r|
                              unless DishCategoryOrder.find_by_dish_category_id_and_restaurant_id(dc.id, r.id)
                                  DishCategoryOrder.create({
                                    :dish_category_id => dc.id,
                                    :network_id => dish_network.id,
                                    :restaurant_id => r.id,
                                    :order => i
                                  })
                                end
                          end
                          i = 0 if review.network_id != network_chk
                          network_chk = review.network_id
                      end
                  end
                  dc_chk = d.category_name
               end

            end
          end
        end
        
      end
    end
    
    
  end
  
  task :match_rwr => :environment do
    Review.group(:network_id).order('network_id DESC').each do |review|
      if review.network.dishes.count < 15
        p "Start with #{review.id}."
        c = 0
        MiRestaurant.where('our_network_id = ?', review.network_id).each do |cr|
          if Restaurant.select(:id).find_by_name_and_address(cr.name, cr.address).blank?
            restaurant_data = {
              :name => cr.name.capitalize_first_letter,
              :address => cr.address,
              :time => cr.worktime,
              :phone => cr.telephone,
              :description => cr.description,
              :web => cr.site,
              :lat => cr.latitude,
              :lon => cr.longitude,
              :network_id => cr.our_network_id,
              :wifi => cr.wifi || 0,
              :station => cr.metro,
              :source => 'web_mi',
            }
          
            c += 1
            restaurant = Restaurant.create(restaurant_data)
            RestaurantImage.create(:remote_photo_url => "http://188.93.18.50/menutka/GetImageMedium/#{cr.picture}.jpg", :restaurant_id => restaurant.id) unless cr.picture.blank?
            p "#{cr.id} #{restaurant_data[:name]} : #{restaurant_data[:address]}"  
          end
        end
        
        d = 0
        if c > 0
          
          Review.includes(:restaurant).select([:id, :restaurant_id]).where('network_id = ?', review.network_id).each do |rev|
            if rest = Restaurant.where("source = 'web_mi' AND network_id = ?", review.network_id).by_distance(rev.restaurant.lat, rev.restaurant.lon)
              
              rev.restaurant_id = rest.first.id          
              if rev.save
                Restaurant.where("source != 'web_mi' AND network_id = ?", review.network_id).each do |nr|
                  nr.destroy
                  d += 1
                end
              end
              
            else
              p "#{rev.restaurant_id} NOT FOUND =("
            end
          end
          
        end
        p "Deleted: #{d}"
        p "Created: #{c}"
        
      end
    end
  end
  
  task :match_r => :environment do
    dd = 0
    
    MiRestaurant.where('our_network_id != 999999').group(:our_network_id).order(:our_network_id).each do |r|
      Network.where(:id => r.our_network_id).each do |n|

        p "Start with #{n.id}.#{n.name}"
        c = 0
        MiRestaurant.where(:our_network_id => r.our_network_id).each do |cr|
          if Restaurant.select(:id).find_by_name_and_address(cr.name, cr.address).blank?
            restaurant_data = {
              :name => cr.name.capitalize_first_letter,
              :address => cr.address,
              :time => cr.worktime,
              :phone => cr.telephone,
              :description => cr.description,
              :web => cr.site,
              :lat => cr.latitude,
              :lon => cr.longitude,
              :network_id => cr.our_network_id,
              :wifi => cr.wifi || 0,
              :station => cr.metro,
              :source => 'web_mi',
            }
            
            c += 1
            restaurant = Restaurant.create(restaurant_data)
            RestaurantImage.create(:remote_photo_url => "http://188.93.18.50/menutka/GetImageMedium/#{cr.picture}.jpg", :restaurant_id => restaurant.id) unless cr.picture.blank?
            p "#{cr.id} #{restaurant_data[:name]} : #{restaurant_data[:address]}"
          end
        end
        
        if c > 0 and n.dishes.count < 20
          d = 0
          revs = n.reviews.select(:restaurant_id)
          n.restaurants.where("source != 'web_mi'").each do |nr|
            revs.each do |rev|
              if rev.restaurant_id == nr.id
                if rest = n.restaurants.where("source = 'web_mi'").by_distance(rev.restaurant.lat, rev.restaurant.lon)
                  rev.restaurant_id = rest.first.id
                  rev.save
                end
              end
            end
            nr.destroy
            d += 1
          end
          p "Deleted: #{d}"
        end
        
        p "Created: #{c}"
      end
    end
    
    p "#{dd} Leaved"
       p "Creating New Networks"
       MiRestaurant.where(:our_network_id => '999999').group(:network_id).each do |r|
         p "Start with #{r.name}"
         network = Network.create(:name => r.name.capitalize_first_letter)
         c = 0 
         MiRestaurant.where(:network_id => r.network_id).each do |cr|
           restaurant_data = {
             :name => cr.name.capitalize_first_letter,
             :address => cr.address,
             :time => cr.worktime,
             :phone => cr.telephone,
             :description => cr.description,
             :web => cr.site,
             :lat => cr.latitude,
             :lon => cr.longitude,
             :network_id => network.id,
             :wifi => cr.wifi || 0,
             :station => cr.metro,
             :source => 'web_mi',
           }
           c += 1
           p "#{restaurant_data[:name]} : #{restaurant_data[:address]}"
           restaurant = Restaurant.create(restaurant_data)
           RestaurantImage.create(:remote_photo_url => "http://188.93.18.50/menutka/GetImageSmall/#{cr.picture}.jpg", :restaurant_id => restaurant.id) unless cr.picture.blank?
         end
         p "Created: #{c}"
    end
    
  end
  
  task :match_n => :environment do
    
    mi_rs = MiRestaurant.group(:network_id).where('our_network_id IS NULL AND city = "MSK"').order(:id)
    mi_rs.each do |mr| 
      
      mr.name.strip!
      
      if network = Network.find_by_name(mr.name)
        p "#{mr.name} : #{network.name}"
        MiRestaurant.where(:network_id => mr.network_id).each do |u| 
          u.our_network_id = network.id
          u.save
        end
      end
      
      if network = Network.find_by_name(Translit.convert(mr.name))
        p "#{mr.name} : #{network.name}"
        MiRestaurant.where(:network_id => mr.network_id).each do |u| 
          u.our_network_id = network.id
          u.save
        end
      end
      
      mr.name.split.each do |nn|
        if nn.length > 2
          
        nn = nn.strip.gsub(/[”“«»\"\"\#`]/, '')
        nn = nn.strip.gsub(/[-]/, ' ')
        nn = nn.strip.gsub('&', ' & ')
        
        if networks = Network.where('name LIKE ?', nn)
            networks.each do |n|
              rs = n.restaurants
              if rs.count == 1
                if (rs.first.lat.to_f - mr.latitude.to_f).abs.round(2) == 0 && (rs.first.lon.to_f - mr.longitude.to_f).abs.round(2) == 0
                  p "#{nn} : #{mr.name} : #{n.name}"
                  mr.our_network_id = n.id
                  mr.save
                else
                  p "#{nn} : #{mr.name} : #{n.name} lat: #{(rs.first.lat.to_f - mr.latitude.to_f).abs.round(5)} lon: #{(rs.first.lon.to_f - mr.longitude.to_f).abs.round(5)}"
                end
              end
            end
          end
      
          if networks = Network.where('name LIKE ?', Translit.convert(nn))
            networks.each do |n|
              rs = n.restaurants
              if rs.count == 1
                if (rs.first.lat.to_f - mr.latitude.to_f).abs.round(2) == 0 && (rs.first.lon.to_f - mr.longitude.to_f).abs.round(2) == 0
                  p "#{nn} : #{mr.name} : #{n.name}"
                  mr.our_network_id = n.id
                  mr.save
                else
                  p "#{nn} : #{mr.name} : #{n.name} lat: #{(rs.first.lat.to_f - mr.latitude.to_f).abs.round(5)} lon: #{(rs.first.lon.to_f - mr.longitude.to_f).abs.round(5)}"
                end
              end
            end
          end
        
        end
      end
      
    end
    p mi_rs.count.count
    
  end
  
  task :group => :environment do
    
    unless MiRestaurant.select(:network_id).order("network_id DESC").limit(1).blank?
      i = MiRestaurant.select(:network_id).order("network_id DESC").first.network_id + 1
    else
      i = 1
    end
    st = 0
    
    # MiDishe.where(:category_id => 6962) {|d| d.destroy}
        
    MiRestaurant.select([:mi_id, :name, :id]).order(:mi_id).where("network_id IS NULL AND city = 'MSK'").each do |r|
      
      p "CHECK: #{r.mi_id} - #{r.name}"
      restaurant_1 = MiRestaurant.select([:mi_id, :name, :id, :network_id]).find_by_mi_id(r.mi_id)
      
      if restaurant_1.network_id.nil? 
        
        restaurant_1.network_id = i
        r_dishes = MiDish.select(:name).where("restaurant_id = ? AND category_id != 13 AND category_id != 16", r.mi_id)
      
        MiRestaurant.select([:mi_id, :name, :id]).order('id DESC').where("city = 'MSK' AND name = ?", r.name).each do |tr|
          MiDish.select(:name).where("restaurant_id = ? AND category_id != 13 AND category_id != 16", tr.mi_id).each do |tr_d|
          
            st = 0
            r_dishes.each do |r_d|
              if tr_d.name == r_d.name
                st = 1
                break
              end
            end
            if st == 0
              i += 1
              break
            end
          
          end
        
          restaurant_2 = MiRestaurant.select([:mi_id, :name, :id, :network_id]).find_by_mi_id(tr.mi_id)
          
          if restaurant_2.network_id.nil?
            restaurant_2.network_id = i
          else 
            restaurant_1.network_id = restaurant_2.network_id
            i = restaurant_2.network_id
          end
          
          if restaurant_1.network_id != restaurant_2.network_id
            p "#{tr.mi_id} - #{tr.name} is not like #{r.mi_id} - #{r.name}"
            restaurant_2.step = 2
          else
            p "#{tr.mi_id} - #{tr.name} is same with #{r.mi_id} - #{r.name}"
          end
          
          restaurant_1.save
          restaurant_2.save
          
        end
      end
      i += 1
    end 
  end
  
  task :update => :environment do
  
    require 'rubygems'
    require 'net/http'
    require 'uri'
    require 'builder'
    require 'xmlsimple'
    
    endpoint = 'http://188.93.18.50/MenutkaSoap/MenutkaSoapService.svc'
    soap = 'http://schemas.xmlsoap.org/soap/envelope/'
    service =  'http://www.w3.org/2002/ws/databinding/examples/6/05/'
    operation = "http://menutka.com/IMenutka/FilterRestaurants"
  
    lat_msk = '55.75354846578458'
    lng_msk = '37.60923964756874'

    lat_spb = '59.95378662114677'
    lng_spb = '30.31354584753765'
  
    module Net
      module HTTPHeader
        def x( k )
          return "SOAPAction" if k == 'soapaction'
          k.split(/-/).map {|i| i.capitalize }.join('-')
        end
      end
    end
  
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host)
    
    # Update Resturants Names    
    operation = "FilterRestaurants"
  
    req_headers= {
      'Content-Type' => 'text/xml; charset=utf-8',
      'User-Agent' => 'wsdl2objc',
      'Accept' => '*/*',
      'SOAPAction' => 'http://menutka.com/IMenutka/' + operation,
      'Connection' => 'keep-alive'
    }
  
    req_body_restaurants = "<?xml version=\"1.0\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
      <soap:Body>
        <tns1:FilterRestaurants>
          <tns1:filters>
            <tns2:Filter>
              <tns2:Id>4</tns2:Id>
              <tns2:NumericValues>
                <tns3:double>#{lat_spb}</tns3:double>
                <tns3:double>#{lng_spb}</tns3:double>
              </tns2:NumericValues>
              <tns2:Switcher>true</tns2:Switcher>
              <tns2:Type>3</tns2:Type>
            </tns2:Filter>
          </tns1:filters>
          <tns1:from>0</tns1:from>
          <tns1:to>9999</tns1:to>
        </tns1:FilterRestaurants>
      </soap:Body>
    </soap:Envelope>"
  
    response = http.request_post(uri.path, req_body_restaurants, req_headers).body.force_encoding("UTF-8")
    data = XmlSimple.xml_in(response, {'KeyAttr' => 'name'})
    restaurants = data['Body'][0]["#{operation}Response"][0]["#{operation}Result"][0]['Restaurant']
  
    restaurants.each do |r|
    
      data = {
        :address => r['Address'][0],
        :description => r['Description'][0],
        :dishes => r['Dishes'][0],
        :mi_id => r['Id'][0],
        :latitude => r['Latitude'][0],
        :longitude => r['Longitude'][0],
        :metro => r['Metro'][0],
        :name => r['Name'][0],
        :picture => r['PictureIds'],
        :site => r['Site'][0],
        :telephone => r['Telephone'][0],
        :wifi => r['WiFi'][0],
        :worktime => r['WorkTime'][0],
        :city => 'SPB'
      }    
      restaurant = MiRestaurant.find_by_mi_id(data[:mi_id])

      if restaurant.blank?

        # Get Dishes    
        operation3 = "GetRestaurantMenu"
        operation4 = "GetDishesDetails"

        r = MiRestaurant.create(data)

          req_body_dishes3 = "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
            <soap:Body>
              <tns1:#{operation3}>
                <tns1:restaurantId>#{r.mi_id}</tns1:restaurantId>
                <tns1:userId>1764</tns1:userId>
              </tns1:#{operation3}>
            </soap:Body>
          </soap:Envelope>"

          req_headers= {
            'Content-Type' => 'text/xml; charset=utf-8',
            'User-Agent' => 'wsdl2objc',
            'Accept' => '*/*',
            'SOAPAction' => 'http://menutka.com/IMenutka/' + operation3,
            'Connection' => 'keep-alive'
          }

          response = http.request_post(uri.path, req_body_dishes3, req_headers).body.force_encoding("UTF-8")
          data = XmlSimple.xml_in(response, {'KeyAttr' => 'name'})

          begin        
            ids = []
            dishes = data['Body'][0]["#{operation3}Response"][0]["#{operation3}Result"][0]['MenuItem']
            dishes.each do |d|
               ids.push("<tns2:int>#{d['Id'][0]}</tns2:int>")
             end

            req_body_dishes4 = "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
              <soap:Body>
                <tns1:GetDishesDetails>
                  <tns1:dishIds>
                    #{ids.join}
                  </tns1:dishIds>
                </tns1:GetDishesDetails>
              </soap:Body>
            </soap:Envelope>"

            req_headers= {
              'Content-Type' => 'text/xml; charset=utf-8',
              'User-Agent' => 'wsdl2objc',
              'Accept' => '*/*',
              'SOAPAction' => 'http://menutka.com/IMenutka/' + operation4,
              'Connection' => 'keep-alive'
            }

            response = http.request_post(uri.path, req_body_dishes4, req_headers).body.force_encoding("UTF-8")
            data = XmlSimple.xml_in(response, { 'KeyAttr' => 'name' })

            begin
              dishes = data['Body'][0]["#{operation4}Response"][0]["#{operation4}Result"][0]['Dish']
              dishes.each do |d|
                  data = {
                       :category_id => d['Category'][0]['Id'][0],
                       :category_name => d['Category'][0]['Name'][0],
                       :category_picture => d['Category'][0]['PictureId'][0],
                       :description => d['Description'][0],
                       :mi_id => d['Id'][0],
                       :kilo_calories => d['KKal'][0],
                       :cousine => d['Kitchens'][0],
                       :latitude => d['Latitude'][0],
                       :longitude => d['Longitude'][0],
                       :likes => d['Likes'][0],
                       :name => d['Name'][0],
                       :pictures => d['PictureIds'][0]['int'],
                       :price => d['Price'][0],
                       :restaurant_id => d['Restaurant'][0]['Id'][0],
                       :restaurant_name => d['Restaurant'][0]['Name'][0],
                       :composition => d['Sostav'][0],
                       :vegetarian => d['Vegas'][0],
                       :weight => d['Weight'][0]
                  }

                 unless MiDish.select(:mi_id).find_by_mi_id(data[:mi_id])
                   MiDish.create(data)
                   p "#{data[:mi_id]} - #{data[:name]}, at #{data[:restaurant_name]} YES!"
                 else
                   p "#{data[:mi_id]} ALREADY EXIST!"
                 end
              end
              p "#{r.mi_id} ok!"
            rescue
              p "#{i} NOT EXIST!"
            end

          rescue
            p "#{r.mi_id} err!"
          end
        end
    end
  end
  
  task :not_found => :environment do
    require 'csv'
    
    MiRestaurant.where(:city => 'MSK').each do |mi_r|
      
      mi_name = mi_r.name.gsub(/^\p{Space}+|\p{Space}+$/, "")
      if n = Network.find_by_name(mi_name)
        n
      elsif r = Restaurant.find_by_name_eng(mi_name)
        r
      elsif n = Network.find_by_name(mi_name.gsub('.', ""))
        n
      elsif r = Restaurant.find_by_name(mi_name)
        r
      else
        
        p "#{mi_r.mi_id} #{mi_r.name} NOT FOUND IN DB"
        log_file_path = File.dirname(__FILE__).sub('/lib/tasks', '') + "/log/#{Time.new.strftime("%F-%H_%M_%S")}_mi_copy.log"
        CSV.open(log_file_path, "a") do |csv|
          csv << ["#{mi_r.mi_id};#{mi_r.name}"]
        end
        
      end
    end
  end
  
  task :copy => :environment do
    require 'csv'
    
    MiRestaurant.where(:city => 'MSK').each do |mi_r|
      
      mi_name = mi_r.name.gsub(/^\p{Space}+|\p{Space}+$/, "")
      if n = Network.find_by_name(mi_name)
        n = n
      elsif r = Restaurant.find_by_name_eng(mi_name)
        n = r.network
        n.name = r.name
        n.save
      elsif n = Network.find_by_name(mi_name.gsub('.', ""))
        n.name = mi_r.name
        n.save
      elsif r = Restaurant.find_by_name(mi_name)
        n = r.network
        n.name = r.name
        n.save
      else
        p "#{mi_r.mi_id} #{mi_r.name} NOT FOUND IN DB"
        log_file_path = File.dirname(__FILE__).sub('/lib/tasks', '') + "/log/#{Time.new.strftime("%F-%H_%M_%S")}_mi_copy.log"
        CSV.open(log_file_path, "a") do |csv|
          csv << ["#{mi_r.mi_id};#{mi_r.name}"]
        end
      end
      
      if n && n.dishes.count < 15
        p "#{n.id} #{n.name}"
      
        if n.dishes.count == 0
          n.restaurants.each {|rest| rest.destroy}
        else
          n.restaurants.each do |r_del|
            r_del.destroy if r_del.reviews.count == 0
          end
        end

        MiRestaurant.where(:name => mi_r.name).each do |mi_ar|
          restaurant_data = {
            :name => mi_ar.name.capitalize_first_letter,
            :address => mi_ar.address,
            :time => mi_ar.worktime,
            :phone => mi_ar.telephone,
            :description => mi_ar.description,
            :web => mi_ar.site,
            :lat => mi_ar.latitude,
            :lon => mi_ar.longitude,
            :network_id => n.id,
            :wifi => mi_ar.wifi || 0,
            :station => mi_ar.metro,
            :source => 'web_mi_u1',
          }
          
          r = Restaurant.create(restaurant_data)
          mi_ar.step = 11
          mi_ar.save
          p "--- #{mi_ar.address}"
          
        end

        i = 0
        dish_category_id_new = 0
        restaurant_id_new = 0
        MiDish.where(:restaurant_id => mi_r.mi_id).each do |mi_d|
        
          dc_name = mi_d.category_name.downcase.gsub(/^\p{Space}+|\p{Space}+$/, "")
          dish_category_id = DishCategory.find_by_name(dc_name) ? DishCategory.find_by_name(dc_name).id : DishCategory.create(:name => dc_name).id

          types = {'1' => 14, '10' => 16, '11' => 15, '13' => 18, '14' => 15, '16' => 18, '17' => 2, '18' => 15,
            '2' => 4, '20' => 17, '3' => 15, '4' => 15, '5' => 15, '594' => 15, '6' => 15, '6906' => 2, '6907' => 2,
            '6961' => 7, '7' => 2, '8' => 14, '9' => 15
          }
    
          sub_types = {'11' => 13, '17' => 28, '18' => 21, '3' => 46, '4' => 7, '5' => 11, '594' => 4, '6' => 19,
            '6907' => 27, '9' => 5
          }
        
          dish_data = {
            :name => mi_d.name,
            :remote_photo_url => mi_d.pictures.blank? ? nil : "http://188.93.18.50/menutka/GetImageMedium/#{mi_d.pictures[/"([\d]+)"/, 1]}.jpg",
            :price => mi_d.price,
            :description => mi_d.description['--- {}'].nil? ? mi_d.description : nil,
            :network_id => n.id,

            :dish_category_id => dish_category_id,
            :dish_type_id => types[mi_d.category_id],
            :dish_subtype_id => sub_types[mi_d.category_id],
            :dish_extratype_id => mi_d.vegetarian == 'true' ? 4 : nil,
          }
        
          unless Dish.find_by_name_and_network_id(dish_data[:name], dish_data[:network_id])
            Dish.create(dish_data)
            p "    --- #{mi_d.name}"  
          
            # Set Dish Category Order
            if dish_category_id_new != dish_category_id
              i += 1
              Restaurant.where(:network_id => r.network_id).each do |r|
                dish_category_order_data = {
                  :restaurant_id => r.id,
                  :network_id => r.network_id,
                  :dish_category_id => dish_category_id,
                  :order => i
                }

                DishCategoryOrder.create(dish_category_order_data)
                dish_category_id_new = dish_category_id
                restaurant_id_new = r.id
              end
            end
          end

          MiRestaurant.where(:name => mi_r.name).each do |mi_ar|
            mi_ar.step = 12
            mi_ar.save
          end
        
        end
      end
    end
  end
  
  
  task :parse, [:type] => :environment do |t, args|
  
    require 'rubygems'
    require 'net/http'
    require 'uri'
    require 'builder'
    require 'xmlsimple'
  
    type = args[:type] ||= 'update_rest_name'
  
    endpoint = 'http://188.93.18.50/MenutkaSoap/MenutkaSoapService.svc'
    soap = 'http://schemas.xmlsoap.org/soap/envelope/'
    service =  'http://www.w3.org/2002/ws/databinding/examples/6/05/'
    operation = "http://menutka.com/IMenutka/FilterRestaurants"
  
  
    lat_msk = '55.75354846578458'
    lng_msk = '37.60923964756874'

    lat_spb = '59.95378662114677'
    lng_spb = '30.31354584753765'
    
    
  
    module Net
      module HTTPHeader
        def x( k )
          return "SOAPAction" if k == 'soapaction'
          k.split(/-/).map {|i| i.capitalize }.join('-')
        end
      end
    end
  
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host)
    
    # Update Resturants Names
    if type == 'update_rest_name'
    
      operation = "FilterRestaurants"
    
      req_headers= {
        'Content-Type' => 'text/xml; charset=utf-8',
        'User-Agent' => 'wsdl2objc',
        'Accept' => '*/*',
        'SOAPAction' => 'http://menutka.com/IMenutka/' + operation,
        'Connection' => 'keep-alive'
      }
    
      req_body_restaurants = "<?xml version=\"1.0\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
        <soap:Body>
          <tns1:FilterRestaurants>
            <tns1:filters>
              <tns2:Filter>
                <tns2:Id>4</tns2:Id>
                <tns2:NumericValues>
                  <tns3:double>#{lat_msk}</tns3:double>
                  <tns3:double>#{lng_msk}</tns3:double>
                </tns2:NumericValues>
                <tns2:Switcher>true</tns2:Switcher>
                <tns2:Type>3</tns2:Type>
              </tns2:Filter>
            </tns1:filters>
            <tns1:from>0</tns1:from>
            <tns1:to>9999</tns1:to>
          </tns1:FilterRestaurants>
        </soap:Body>
      </soap:Envelope>"
    
      response = http.request_post(uri.path, req_body_restaurants, req_headers).body.force_encoding("UTF-8")
      data = XmlSimple.xml_in(response, {'KeyAttr' => 'name'})
      restaurants = data['Body'][0]["#{operation}Response"][0]["#{operation}Result"][0]['Restaurant']
    
      restaurants.each do |r|
      
        data = {
          :address => r['Address'][0],
          :description => r['Description'][0],
          :dishes => r['Dishes'][0],
          :mi_id => r['Id'][0],
          :latitude => r['Latitude'][0],
          :longitude => r['Longitude'][0],
          :metro => r['Metro'][0],
          :name => r['Name'][0],
          :picture => r['PictureIds'],
          :site => r['Site'][0],
          :telephone => r['Telephone'][0],
          :wifi => r['WiFi'][0],
          :worktime => r['WorkTime'][0],
          :city => 'SPB'
        }
      
        if r = MiRestaurant.find_by_mi_id(data[:mi_id])
          # r.name = data[:name]
          r.picture = data[:picture]
          r.save
          p "#{data[:name]}, #{data[:address]} DONE!"
        end
      end  
    end
  
    # Get Resturants
    if type == 'restaurants'
    
      operation = "FilterRestaurants"
    
      req_headers= {
        'Content-Type' => 'text/xml; charset=utf-8',
        'User-Agent' => 'wsdl2objc',
        'Accept' => '*/*',
        'SOAPAction' => 'http://menutka.com/IMenutka/' + operation,
        'Connection' => 'keep-alive'
      }
    
      req_body_restaurants = "<?xml version=\"1.0\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
        <soap:Body>
          <tns1:FilterRestaurants>
            <tns1:filters>
              <tns2:Filter>
                <tns2:Id>4</tns2:Id>
                <tns2:NumericValues>
                  <tns3:double>#{lat_msk}</tns3:double>
                  <tns3:double>#{lng_msk}</tns3:double>
                </tns2:NumericValues>
                <tns2:Switcher>true</tns2:Switcher>
                <tns2:Type>3</tns2:Type>
              </tns2:Filter>
            </tns1:filters>
            <tns1:from>0</tns1:from>
            <tns1:to>9999</tns1:to>
          </tns1:FilterRestaurants>
        </soap:Body>
      </soap:Envelope>"
    
      response = http.request_post(uri.path, req_body_restaurants, req_headers).body.force_encoding("UTF-8")
      data = XmlSimple.xml_in(response, {'KeyAttr' => 'name'})
      restaurants = data['Body'][0]["#{operation}Response"][0]["#{operation}Result"][0]['Restaurant']
    
      restaurants.each do |r|
      
        data = {
          :address => r['Address'][0],
          :description => r['Description'][0],
          :dishes => r['Dishes'][0],
          :mi_id => r['Id'][0],
          :latitude => r['Latitude'][0],
          :longitude => r['Longitude'][0],
          :metro => r['Metro'][0],
          :name => r['Name'][0],
          :picture => r['PictureIds'][/"([\d]+)"/, 1],
          :site => r['Site'][0],
          :telephone => r['Telephone'][0],
          :wifi => r['WiFi'][0],
          :worktime => r['WorkTime'][0],
          :city => 'MSK'
        }
      
        unless MiRestaurant.find_by_mi_id(data[:mi_id])
          MiRestaurant.create(data)
          p "#{data[:name]}, #{data[:address]} YES!"
        else
          p "#{data[:mi_id]} ALREADY EXIST!"
        end
      end  
    end
  
    # Get Dishes
    if type == 'dishes'
    
      operation3 = "GetRestaurantMenu"
      operation4 = "GetDishesDetails"
    
      MiRestaurant.select(:mi_id).where('id > 1733').order(:id).each do |r|
    
        req_body_dishes3 = "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
          <soap:Body>
            <tns1:#{operation3}>
              <tns1:restaurantId>#{r.mi_id}</tns1:restaurantId>
              <tns1:userId>1764</tns1:userId>
            </tns1:#{operation3}>
          </soap:Body>
        </soap:Envelope>"
    
        req_headers= {
          'Content-Type' => 'text/xml; charset=utf-8',
          'User-Agent' => 'wsdl2objc',
          'Accept' => '*/*',
          'SOAPAction' => 'http://menutka.com/IMenutka/' + operation3,
          'Connection' => 'keep-alive'
        }

        response = http.request_post(uri.path, req_body_dishes3, req_headers).body.force_encoding("UTF-8")
        data = XmlSimple.xml_in(response, { 'KeyAttr' => 'name' })
    
        begin        
          ids = []
          dishes = data['Body'][0]["#{operation3}Response"][0]["#{operation3}Result"][0]['MenuItem']
          dishes.each do |d|
             ids.push("<tns2:int>#{d['Id'][0]}</tns2:int>")
           end

          req_body_dishes4 = "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:MenutkaService=\"http://tempuri.org/\" xmlns:tns1=\"http://menutka.com\" xmlns:ns1=\"http://menutka.com/Imports\" xmlns:tns2=\"http://schemas.datacontract.org/2004/07/MenutkaPrivateService\" xmlns:tns3=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:tns4=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">
            <soap:Body>
              <tns1:GetDishesDetails>
                <tns1:dishIds>
                  #{ids.join}
                </tns1:dishIds>
              </tns1:GetDishesDetails>
            </soap:Body>
          </soap:Envelope>"
            
          req_headers= {
            'Content-Type' => 'text/xml; charset=utf-8',
            'User-Agent' => 'wsdl2objc',
            'Accept' => '*/*',
            'SOAPAction' => 'http://menutka.com/IMenutka/' + operation4,
            'Connection' => 'keep-alive'
          }
            
          response = http.request_post(uri.path, req_body_dishes4, req_headers).body.force_encoding("UTF-8")
          data = XmlSimple.xml_in(response, { 'KeyAttr' => 'name' })
        
          begin
            dishes = data['Body'][0]["#{operation4}Response"][0]["#{operation4}Result"][0]['Dish']
            dishes.each do |d|
                data = {
                     :category_id => d['Category'][0]['Id'][0],
                     :category_name => d['Category'][0]['Name'][0],
                     :category_picture => d['Category'][0]['PictureId'][0],
                     :description => d['Description'][0],
                     :mi_id => d['Id'][0],
                     :kilo_calories => d['KKal'][0],
                     :cousine => d['Kitchens'][0],
                     :latitude => d['Latitude'][0],
                     :longitude => d['Longitude'][0],
                     :likes => d['Likes'][0],
                     :name => d['Name'][0],
                     :pictures => d['PictureIds'][0]['int'],
                     :price => d['Price'][0],
                     :restaurant_id => d['Restaurant'][0]['Id'][0],
                     :restaurant_name => d['Restaurant'][0]['Name'][0],
                     :composition => d['Sostav'][0],
                     :vegetarian => d['Vegas'][0],
                     :weight => d['Weight'][0]
                }

                unless MiDish.select(:mi_id).find_by_mi_id(data[:mi_id])
                 MiDish.create(data)
                 p "#{data[:mi_id]} - #{data[:name]}, at #{data[:restaurant_name]} YES!"
                else
                 p "#{data[:mi_id]} ALREADY EXIST!"
                end
            end
            p "#{r.mi_id} ok!"
          rescue
            p "#{i} NOT EXIST!"
          end
    
        rescue
          p "#{r.mi_id} err!"
        end
      end
    end
  end
  
  
end
