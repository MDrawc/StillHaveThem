class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  layout  '_landing', :only => [:edit, :update]

  def new
    respond_to :js
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      respond_to :js
    else
      respond_to do |format|
        format.js { render partial: 'get_email_error' }
      end
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      reset_error
    elsif @user.update_attributes(user_params)
      log_in @user
      respond_to :js
    else
      reset_error
    end
  end

  private
    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        render 'shared/wrong_link'
      end
    end

    def user_params
      params.require(:user).permit(:password)
    end

    def check_expiration
      if @user.password_reset_expired?
        render 'shared/wrong_link'
      end
    end

    def reset_error
      respond_to do |format|
        format.js { render partial: 'reset_error' }
      end
    end
end
