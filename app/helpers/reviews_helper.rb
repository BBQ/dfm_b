module ReviewsHelper
  
  def friends(review)
    friends_with = []
    if review.friends
      review.friends.split(',').each do |u|
        if user = User.find_by_id(u)
          friends_with.push({
            :id => user.id,
            :name => user.name,
            :photo => user.user_photo
          })
        elsif user = u.split('@@@')
          user[0] = "http://graph.facebook.com/#{user[0]}/picture?type=square" if user[0].to_i != 0
          friends_with.push({
            :id => 0,
            :name => user[1],
            :photo => user[0],
          })
        end
      end
    end
    friends_with
  end
  
  def likes(review_id, self_review = nil)
    
    if self_review.nil?
      likes = Like.where(:review_id => review_id)
    else
      likes = DishLike.where(:review_id => review_id)
    end
    
    likes_a = []
    if likes.count > 0
      User.where("id IN (#{likes.collect {|l| l.user_id}.join(',')})").each do |u|
        likes_a.push({
          :id => u.id,
          :name => u.name,
          :photo => u.user_photo
        })
      end
    end
    likes_a
  end
  
  def comments(review, self_review = nil)

    if self_review.nil?
      cms = Comment.where(:review_id => review.id).order("created_at DESC").limit(5)
    else
      cms = DishComment.where(:dish_id => review.dish_id).order("created_at DESC").limit(5)
    end
    
    comments_a = []    
    cms.each do |c|
      comments.push({
        :name => c.user.name,
        :photo => c.user.user_photo,
        :text => c.text
      })
    end
    comments_a
  end
  
end
