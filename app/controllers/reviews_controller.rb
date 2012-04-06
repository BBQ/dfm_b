class ReviewsController < ApplicationController
  
  def index
    @reviews = Review.order('id DESC')
    @i_like = Like.where("user_id = ?", current_user.id) if current_user
    
    # return render :json => @reviews.as_json 
  end
  
  def search
    if params[:type] && params[:search][:find]
      @reviews = Review.where("dish_id IN (SELECT id FROM dishes WHERE LOWER(name) REGEXP '[[:<:]]#{params[:search][:find].downcase}')").order('rating DESC')
      @i_like = Like.where("user_id = ?", current_user.id) if current_user
    end
  end
  
  def show
    if params[:id]
      
      @review = Review.find_by_id(params[:id])
      @r_categories = RestaurantCategory.where("id IN (#{@review.restaurant.restaurant_categories})").collect { |c| c.name}.join(', ')
    
      @bill = []
      @review.restaurant.bill.to_i.times do
        @bill.push('$')
      end
      @bill = @bill.join('')
    
      @markers = []
      @review.network.restaurants.each { |r| @markers.push("['#{r.name}', #{r.lat}, #{r.lon}, 1]")}
      @markers = "[#{@markers.join(',')}]"
    
      @friends_with = []
      if @review.friends
        @review.friends.split(',').each do |u|
          if user = User.find_by_id(u)
            @friends_with.push({
              :id => user.id,
              :name => user.name,
              :photo => user.user_photo
            })
          elsif user = u.split('@@@')
            user[0] = "http://graph.facebook.com/#{user[0]}/picture?type=square" if user[0].to_i != 0
            @friends_with.push({
              :id => 0,
              :name => user[1],
              :photo => user[0],
            })
          end
        end
      end
    
      @likes = []
      likes = Like.where(:review_id => params[:id])
      if likes.count > 0
        User.where("id IN (#{likes.collect {|l| l.user_id}.join(',')})").each do |u|
          @likes.push({
            :id => u.id,
            :name => u.name,
            :photo => u.user_photo
          })
        end
      end
      
      @comments = []
      Comment.where(:review_id => params[:id]).order("created_at DESC").limit(5).each do |c|
        @comments.push({
          :name => c.user.name,
          :photo => c.user.user_photo,
          :text => c.text
        })
      end
      
      r_arr = Review.where(:dish_id => @review.dish_id).collect {|r| r.id}
      
      if next_index = r_arr.find_index(@review.id) + 1
        @review_next_id = r_arr[0] unless @review_next_id = r_arr[next_index]           
      end
      
      if prev_index = r_arr.find_index(@review.id) - 1
        @review_prev_id = r_arr[prev_index] 
      end
      
      
      
    end
  end
  
  def delete
    if review = Review.find_by_id(params[:id])
      data = review.delete
    end
    return render :json => data
  end
  
end
