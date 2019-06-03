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
      log_in(user)
      redirect_to root_url
    else
      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
