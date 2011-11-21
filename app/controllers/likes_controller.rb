class LikesController < ApplicationController
  def add
    if current_user && params[:id]
      @review = Like.new.save_me(current_user.id, params[:id])
      @cu = current_user
    end
  end
end
