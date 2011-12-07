# encoding: utf-8
task :snc_up => :environment do

  Network.all.each do |n|
    if n.reviews.count < 1
      # Удаляем все Блюда, Рестораны, Сети без ревью
      n.dishes.each {|d| d.destroy}
      n.restaurants.each {|r| r.destroy}
      puts n.name
      n.destroy
          
    else # Сети с ревью
      
      # Удаляем блюда без ревью 
      n.dishes.each {|d| d.destroy if d.reviews.count < 1}

      # Удаляем рестораны без ревью 
      n.restaurants.each do |r|
        d = 1
        n.reviews.each {|w| d = 0 if w.restaurant_id == r.id}
        r.destroy if d == 1
      end
      
    end       
  end
end