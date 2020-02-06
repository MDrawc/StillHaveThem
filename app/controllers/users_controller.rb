class UsersController < ApplicationController
  before_action :require_user, except: [:new, :create]

  def new
    @user = User.new
    respond_to :js
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.create_initial_collections
      @user.send_activation_email
      respond_to do |format|
            format.js { render partial: 'shared/auth_needed',
              locals: { email: @user.email, selector: '#signup-modal' } }
      end
    else
      @errors = @user.errors.messages
      respond_to :js
    end
  end

  def update
    @is_it_password = false
    if user_params.keys.first == 'email'
      if current_user.update(user_params)
        current_user.deactivate_and_send_new
        current_user.forget
        respond_to :js
      else
        update_errors(current_user.errors.full_messages)
      end
    else
      @is_it_password = true
      if user_params[:password].empty?
        update_errors(['Password can\'t be blank'])
      elsif current_user.update(user_params)
        respond_to :js
      else
        update_errors(current_user.errors.full_messages)
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

  def settings
    if params[:password]
      if current_user.authenticate(params[:password])
        @user = current_user
        respond_to :js
      else
        respond_to do |format|
            format.js { render partial: 'access_error' }
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

    def update_errors(errors)
      @errors = errors
      respond_to do |format|
          format.js { render partial: "set_errors" }
      end
    end
end
