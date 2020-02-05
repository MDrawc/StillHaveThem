class SharesController < ApplicationController
  layout 'shared'
  before_action :require_user, except: [:shared, :leave]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def new
    @share = Share.new
    get_shares_with_coll_names
    respond_to :js
  end

  def create
    @share = current_user.shares.build(share_params)
    if @share.save
      get_shares_with_coll_names
      respond_to :js
    else
      respond_to do |format|
          format.js { render partial: "error", locals: { errors: @share.errors,
            form: '#share-form', type: ''} }
      end
    end
  end

  def edit
    respond_to :js
  end

  def update
    @share.attributes = share_params
    if @share.save(touch: false)
      find_coll_name
      respond_to :js
    else
      respond_to do |format|
          format.js { render partial: "error", locals: { errors: @share.errors, form: "#ed-share-form-#{ @share.id }", type: 'ed-'}  }
      end
    end
  end

  def shared
    share = Share.find_by(token: params[:token])
    if share
      share.note_visit
      log_guest(share)
      @first_id = share.shared.first
      @no_message = share.message.empty?
    else
      kill_guest
      render 'wrong_link', locals: { link: shared_url(params[:token]) }
    end
  end

  def destroy
    @share.destroy
    get_shares_with_coll_names
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

    def get_shares_with_coll_names
      @shares = current_user.shares
      colls = current_user.collections.pluck(:id, :name).to_h
      @shares_coll_names = @shares.map { |s|
        res = [s.id, s.shared.map { |i| colls[i] }]
      }.to_h
    end

    def find_coll_name
      colls = current_user.collections.pluck(:id, :name).to_h
      @shares_coll_names = {
        @share.id => @share.shared.map { |i| colls[i] }
      }.to_h
    end
end
