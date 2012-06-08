task :top_exp => :environment do
  
  # Restaurant expert
  Restaurant.update_all({:top_user_id => 0})
  Review.where("restaurant_id IS NOT NULL AND rtype IS NULL").group(:restaurant_id).each do |r|
    
    if user_id = (Review.where('restaurant_id = ? AND photo IS NOT NULL', r.restaurant_id).group(:user_id).count).max
      user_id = user_id[0]
    elsif user_id = (Review.where('restaurant_id = ? AND photo IS NULL', r.restaurant_id).group(:user_id).count).max
      user_id = user_id[0]
    end
    
    restaurant = r.restaurant
    restaurant.update_attributes(:top_user_id => user_id)
    p restaurant.name
  end
  
  # Delivery expert
  Delivery.update_all({:top_user_id => 0})
  Review.where("restaurant_id IS NOT NULL AND rtype = 'delivery'").group(:restaurant_id).each do |r|
    
    if user_id = (Review.where("restaurant_id = ? AND photo IS NOT NULL AND rtype = 'delivery'", r.restaurant_id).group(:user_id).count).max
      user_id = user_id[0]
    elsif user_id = (Review.where("restaurant_id = ? AND photo IS NULL AND rtype = 'delivery'", r.restaurant_id).group(:user_id).count).max
      user_id = user_id[0]
    end
    
    user_id = Review.where("restaurant_id = ? AND rtype = 'delivery'", r.restaurant_id).group(:user_id).order('COUNT(user_id) DESC').first.user_id
    restaurant = Delivery.find_by_id(r.restaurant_id)
    restaurant.update_attributes(:top_user_id => user_id)
    p restaurant.name
  end
  
  # Dish expert
  Dish.update_all({:top_user_id => 0})
  Review.where('rtype IS NULL').group(:dish_id).each do |d|
    p d.id
    if user_id = (Review.where("dish_id = ? AND photo IS NOT NULL AND rtype IS NULL", d.dish_id).group(:user_id).count).max
      user_id = user_id[0]
    elsif user_id = (Review.where("dish_id = ? AND photo IS NULL AND rtype IS NULL", d.dish_id).group(:user_id).count).max
      user_id = user_id[0]
    end
    
    dish = d.dish
    dish.update_attributes(:top_user_id => user_id)
    p dish.name
  end
  
  # Home cooked expert
  HomeCook.update_all({:top_user_id => 0})
  Review.where(:rtype => 'home_cooked').group(:dish_id).each do |d|

    if user_id = (Review.where("dish_id = ? AND photo IS NOT NULL AND rtype = 'home_cooked'", d.dish_id).group(:user_id).count).max
      user_id = user_id[0]
    elsif user_id = (Review.where("dish_id = ? AND photo IS NULL AND rtype = 'home_cooked'", d.dish_id).group(:user_id).count).max
      user_id = user_id[0]
    end

    dish = HomeCook.find_by_id(d.dish_id)
    dish.update_attributes(:top_user_id => user_id)
    p dish.name
  end
  
  # Delivery expert
  Delivery.update_all({:top_user_id => 0})
  Review.where(:rtype => 'delivery').group(:dish_id).each do |d|
    
    if user_id = (Review.where("dish_id = ? AND photo IS NOT NULL AND rtype = 'delivery'", d.dish_id).group(:user_id).count).max
      user_id = user_id[0]
    elsif user_id = (Review.where("dish_id = ? AND photo IS NULL AND rtype = 'delivery'", d.dish_id).group(:user_id).count).max
      user_id = user_id[0]
    end
    
    dish = Delivery.find_by_id(d.dish_id)
    dish.update_attributes(:top_user_id => user_id)
    p dish.name
  end
  
end