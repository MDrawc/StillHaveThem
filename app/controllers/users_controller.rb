class UsersController < ApplicationController
  def new
    @user = User.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_url
    else
      @errors = @user.errors
      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
