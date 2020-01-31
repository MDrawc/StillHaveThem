class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])

      user.activate
      user.create_initial_collections


      log_in user
      reload #is this needed?
      #reload does not work it is not remote true
      #notification
    else
      #FIX THIS
      redirect_to root_url
    end
  end
end
