class SessionsController < ApplicationController

  def new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:rem_me] == '1' ? remember(user) : forget(user)
        reload
      else
        respond_to do |format|
            format.js { render partial: 'shared/auth_needed',
              locals: { email: user.email, selector: '#signin-modal' } }
        end
      end
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
