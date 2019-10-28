class SharesController < ApplicationController
  before_action :require_user, except: [:shared]

  def new
  end

  def create
  end

  def destroy
  end

  def shared
    share = Share.find_by_id(params[:share_id])
    if share && params[:key] == share.key
      share.note_visit
      log_out if logged_in?
      log_guest(share)
    else
      redirect_to root_url
    end
  end

end
