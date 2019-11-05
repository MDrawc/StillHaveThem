class SharesController < ApplicationController
  layout 'shared'
  before_action :require_user, except: [:shared, :wrong_link, :leave]
  before_action :correct_user, only: [:destroy]

  def new
    @share = Share.new
    get_shares
    respond_to :js
  end

  def create
    @share = current_user.shares.build(share_params)
    if @share.save
      get_shares
      respond_to :js
    else
      respond_to do |format|
          format.js { render partial: "error", locals: { errors: @share.errors } }
      end
    end
  end

  def shared
    share = Share.find_by(token: params[:token])
    if share
      share.note_visit
      log_guest(share)
      @first_id = share.shared.first
    else
      redirect_to action: 'wrong_link', token: params[:token]
    end
  end

  def wrong_link
    kill_guest
    @link = "www.stillhavethem.com/shared/#{ params[:token] }"
  end

  def destroy
    @share.destroy
    get_shares
    respond_to :js
  end

  def leave
    kill_guest
    redirect_to root_url
  end

  private
    def share_params
      params.require(:share).permit(:title, :message, shared: [])
    end

    def correct_user
      @share = current_user.shares.find_by(id: params[:id])
      reload if @share.nil?
    end

    def get_shares
      @shares = current_user.shares
    end
end
