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
      respond_to do |format|
        format.js {render js: 'location.reload();' }
      end
    else
      @errors = @user.errors.messages
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
