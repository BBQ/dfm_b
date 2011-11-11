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
  
  def delete
    if user_signed_in? && params[:comment_id]
      comment = Comment.new                
      @result = comment.delete(current_user.id, params[:comment_id])
    end
  end
  
end
