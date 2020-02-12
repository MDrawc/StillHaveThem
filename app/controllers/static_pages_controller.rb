class StaticPagesController < ApplicationController
  before_action :require_user, only: [:search_page]
  layout  '_landing', :only => [:info, :doc]
  respond_to :js, except: :home

  def home
    if logged_in?
      url = GetLastVisitedPath.call(user: current_user, cookie: cookies[:last])
      render 'home', locals: { url: url }
    else
      @just_land = true
      render :partial => 'not_logged', :layout => 'landing'
    end
  end

  def info
    @doc = params[:doc]
  end

  def doc
    @doc = params[:doc]
  end

  def search_page
    @history_records = current_user.records
  end
end
