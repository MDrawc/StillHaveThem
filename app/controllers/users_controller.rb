class UsersController < ApplicationController
  before_action :set_user, only: [:destroy]
  before_action :require_same_user, only: [:destroy]



  before_action :require_user, only: [:change_gpv]

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

  def change_gpv
    current_user.update(user_params)
    respond_to :js
  end

  def destroy
    @user.destroy
    redirect_to root_url
  end

  def settings
    respond_to :js
  end

  private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :games_per_view)
    end

    def set_user
      @user = User.find(params[:id])
    end

    def require_same_user
      if current_user != @user
        reload
      end
    end

end
