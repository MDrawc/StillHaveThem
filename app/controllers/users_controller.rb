class UsersController < ApplicationController
  before_action :require_user, except: [:new, :create]

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

  def update
    if current_user.update(user_params)
      respond_to :js
    else
      @errors = current_user.errors.full_messages
      @is_it_password = !!user_params[:password]
      respond_to do |format|
          format.js { render partial: "set_errors" }
      end
    end
  end

  def change_gpv
    current_user.update(user_params)
    respond_to :js
  end

  def destroy
    current_user.destroy
    redirect_to root_url
  end

  def access_settings
    respond_to :js
  end

  def settings
    if params[:password]
      if current_user.authenticate(params[:password])
        @user = current_user
        respond_to :js
      else
        respond_to do |format|
            format.js { render partial: 'access_error',
             locals: { error: 'Wrong password' } }
        end
      end
    else
      respond_to do |format|
          format.js { render partial: 'authorize' }
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :games_per_view)
    end
end
