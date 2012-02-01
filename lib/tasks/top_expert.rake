task :top_exp => :environment do
  
  # Restaurant expert
  Review.group(:restaurant_id).each do |r|
    usr_id = Review.where(:restaurant_id => r.restaurant_id).group(:user_id).order('COUNT(user_id) DESC').first.user_id
    rest = Restaurant.find_by_id(r.restaurant_id)
    rest.top_user_id = usr_id
    p rest.save
  end
  
  # Dish expert
  Review.group(:dish_id).each do |d|
    usr_id = Review.where(:dish_id => d.dish_id).group(:user_id).order('COUNT(user_id) DESC').first.user_id
    dsh = Dish.find_by_id(d.dish_id)
    dsh.top_user_id = usr_id
    p dsh.save
  end
  
end