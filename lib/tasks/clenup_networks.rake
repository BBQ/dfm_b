# encoding: utf-8
task :snc_up => :environment do

  Network.all.each do |n|
    if n.reviews.count < 1
      # Удаляем все Блюда, Рестораны, Сети без ревью
      n.dishes.each {|d| d.destroy}
      n.restaurants.each {|r| r.destroy}
      n.destroy
      puts n.name
    
    else # Сети с ревью
      
      # Удаляем блюда без ревью 
      n.dishes.each do |d|
        if d.reviews.count < 1 
          puts d.name
          d.destroy
        end
      end
      
      # Удаляем рестораны без ревью 
      n.restaurants.each do |r|
        d = 1
        n.reviews.each do |rw|
          d = 0 if rw.restaurant_id == r.id
        end
        if d == 1
          puts r.name
          r.destroy 
        end
      end
      
    end       
  end
end