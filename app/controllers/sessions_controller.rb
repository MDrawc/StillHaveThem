class SessionsController < ApplicationController
  def new
    respond_to :js
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:rem_me] == '1' ? remember(user) : forget(user)
        reload
      else
        js_partial('shared/auth_needed', { email: user.email,
                                           selector: '#signin-modal' })
      end
    else
      respond_to :js
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def async_destroy
    log_out if logged_in?
    reload
  end
end
