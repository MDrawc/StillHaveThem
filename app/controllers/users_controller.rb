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
      create_initial_collections(@user)
      log_in(@user)
      reload
    else
      @errors = @user.errors.messages
      respond_to do |format|
        format.js
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def settings
    respond_to :js
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
