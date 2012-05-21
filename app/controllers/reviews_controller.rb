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
      
      
      if params[:id].count('-') > 0 
        @dish = Dish.find_by_id(params[:id].sub('-', ''))
        @review = Review.new
        @review.id = "-#{@dish.id}"
        @review.user_id = 1
        @review.dish_id = @dish.id
        @review.rating = @dish.rating
        @review.text = @dish.description
        @review.restaurant_id = @dish.network.restaurants.first.id
        @review.network_id = @dish.network.id
      else
        @review = Review.find_by_id(params[:id])
      end
        
      if @review
        if @review.rtype.nil?
 
          @r_categories = RestaurantCategory.where("id IN (#{@review.restaurant.restaurant_categories})").collect { |c| c.name}.join(', ')
    
          @bill = []
          @review.restaurant.bill.to_i.times do
            @bill.push('$')
          end
          @bill = @bill.join('')
    
          @markers = []
          @review.network.restaurants.select([:name, :lat, :lon]).each { |r| @markers.push("['#{r.name}', #{r.lat}, #{r.lon}, 1]")}
          @markers = "[#{@markers.join(',')}]"
          
        elsif @review.rtype == 'home_cooked'
          @r_categories = ''
          @bill = ''
          @markers = []
          
          @review.dish = Dish.new
          @review.dish.name = ''
          
          if hc = HomeCook.find_by_id(@review.dish_id)
            @review.dish.name = hc.name
            @review.dish.rating = hc.rating
            @review.dish.votes = hc.votes
          end

          
        end
        
        @fb_obj = @review
    
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
