class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      redirect_to root_url
    else
      render 'shared/wrong_link', layout: '_landing'
    end
  end

  def resend_activation_link
    email = params[:email]
    user = User.find_by(email: email)
    if user && !user.activated?
      user.new_activation_digest
      user.send_activation_email
      @email = user.email
      respond_to :js
    else
      reload
    end
  end
end
