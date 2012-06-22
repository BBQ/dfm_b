class UsersController < ApplicationController
  
  def show
    if @user = User.find_by_id(params[:id])
      
      @followers = []
      Follower.where("user_id = ? ", @user.id).each do |f|
        @followers.push({:photo => User.find_by_id(f.follow_user_id).user_photo})
      end
      
      @friends = []
      Follower.where("follow_user_id = ? ", @user.id).each do |f|
        @friends.push({:photo => User.find_by_id(f.user_id).user_photo})
      end
      
      @dishins = []
      Review.where('user_id = ? AND rtype IS NULL', @user.id).order('id DESC').take(12).each do |r|
        if dish = Dish.find_by_id(r.dish_id)          
            @dishins.push({:id => dish.id, :photo => dish.image_p120, :name => dish.name})
        end
      end
      
      @likes = []
      Like.where(:user_id => @user.id).each do |l|
        if review = Review.find_by_id(l.review_id)
          if dish = Dish.find_by_id(review.dish_id)          
              @likes.push({:id => dish.id, :photo => dish.image_p120, :name => dish.name})
              break if @likes.count == 10
          end
        end
      end
      
    end
  end
  

  def recover
    if params[:id]
      
      if user = User.find_by_crypted_password(params[:id])
        @user = user
      end
      
    elsif params[:user][:id] && params[:user][:password] && params[:user][:password] == params[:user][:password_confirmation]
      
      if user = User.find_by_id_and_crypted_password(params[:user][:id], params[:user][:crypted_password])
        @message = 'Your password has been changed successfully!' if user.update_password params[:user][:password]
      end
      
    end
  end

end
