class SharesController < ApplicationController
  layout 'shared'
  before_action :require_user, except: [:shared]

  def new
  end

  def create
  end

  def shared
    share = Share.find_by_id(params[:share_id])
    if share && params[:key] == share.key
      share.note_visit
      log_guest(share)
    else
      redirect_to root_url
    end
  end

  def destroy
    kill_guest
    redirect_to root_url
  end
end
