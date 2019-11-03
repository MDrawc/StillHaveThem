class SharesController < ApplicationController
  layout 'shared'
  before_action :require_user, except: [:shared, :wrong_link, :destroy]

  def new
  end

  def create
  end

  def shared
    share = Share.find_by_id(params[:share_id])
    if share && params[:key] == share.key
      share.note_visit
      log_guest(share)
      @first_id = share.shared.first
    else
      redirect_to action: 'wrong_link', id: params[:share_id], key: params[:key]
    end
  end

  def wrong_link
    kill_guest
    @link = "www.stillhavethem.com/shared/#{ params[:id] }/#{ params[:key] }"
  end

  def destroy
    kill_guest
    redirect_to root_url
  end
end
