task :top_exp => :environment do
  
  # Restaurant expert
  Restaurant.update_all({:top_user_id => 0})
  Review.where("restaurant_id IS NOT NULL AND rtype IS NULL").group(:restaurant_id).each do |r|
    user_id = Review.where("restaurant_id = ? AND rtype IS NULL", r.restaurant_id).group(:user_id).order('COUNT(user_id) DESC').first.user_id
    restaurant = Restaurant.find_by_id(r.restaurant_id)
    restaurant.top_user_id = user_id
    p restaurant.save
  end
  
  # Delivery expert
  Delivery.update_all({:top_user_id => 0})
  Review.where("restaurant_id IS NOT NULL AND rtype = 'delivery'").group(:restaurant_id).each do |r|
    user_id = Review.where("restaurant_id = ? AND rtype = 'delivery'", r.restaurant_id).group(:user_id).order('COUNT(user_id) DESC').first.user_id
    restaurant = Delivery.find_by_id(r.restaurant_id)
    restaurant.top_user_id = user_id
    p restaurant.save
  end
  
  # Dish expert
  Dish.update_all({:top_user_id => 0})
  Review.where('rtype IS NULL').group(:dish_id).each do |d|
    user_id = Review.where("dish_id = ? AND rtype IS NULL", d.dish_id).group(:user_id).order('COUNT(user_id) DESC').first.user_id
    dish = Dish.find_by_id(d.dish_id)
    dish.top_user_id = user_id
    p dish.save
  end
  
  # Home cooked expert
  HomeCook.update_all({:top_user_id => 0})
  Review.where(:rtype => 'home_cooked').group(:dish_id).each do |d|
    user_id = Review.where("dish_id = ? AND rtype = 'home_cooked'", d.dish_id).group(:user_id).order('COUNT(user_id) DESC').first.user_id
    dish = HomeCook.find_by_id(d.dish_id)
    dish.top_user_id = user_id
    p dish.save
  end
  
  # Delivery expert
  Delivery.update_all({:top_user_id => 0})
  Review.where(:rtype => 'delivery').group(:dish_id).each do |d|
    user_id = Review.where("dish_id = ? AND rtype = 'delivery'", d.dish_id).group(:user_id).order('COUNT(user_id) DESC').first.user_id
    dish = Delivery.find_by_id(d.dish_id)
    dish.top_user_id = user_id
    p dish.save
  end
  
end