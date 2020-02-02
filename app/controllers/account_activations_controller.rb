class AccountActivationsController < ApplicationController
  layout  '_landing', :only => [:wrong_activ_link]

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      redirect_to root_url
    else
      redirect_to root_url
    end
  end

  def resend_activation_link
    email = params[:email]
    user = User.find_by(email: email)
    if user && !user.activated?
      user.new_activation_digest
      user.send_activation_email
        respond_to do |format|
            format.js { render partial: 'shared/auth_needed',
              locals: { email: user.email, selector: '#signin-modal' } }
        end
    else
      reload
    end
  end
end
