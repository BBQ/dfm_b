class LikesController < ApplicationController
  def add
    if current_user && params[:id]
      like = Like.new.unlike?(current_user.id, params[:id])
      @like = like if like
      @review = Like.new.save_me(current_user.id, params[:id])
    end
  end
end
