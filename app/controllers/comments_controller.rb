class CommentsController < ApplicationController

  def add
    if current_user.id && params[:comment] && params[:id]
        comment = Comment.new                
        if comment.add({:user_id => current_user.id, :review_id => params[:id], :text => params[:comment]})
          @review = Review.find_by_id(params[:id])
          @comments = Comment.where("review_id = ?",params[:id]).order('id')
        end
      end
    end
  
end
