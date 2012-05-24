class UsersController < ApplicationController

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
