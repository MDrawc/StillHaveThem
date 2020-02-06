class StaticPagesController < ApplicationController
  before_action :require_user, only: [:search_page]
  layout  '_landing', :only => [:info, :doc]

  def home
    if logged_in?
      last_id = cookies['last']
      if current_user.collection_ids.include?(last_id.to_i)
        home_id = last_id
      elsif last_id != 'search'
        home_id = current_user.collections.first.id if !current_user.collections.empty?
      end
      url = home_id ? "/collections/#{ home_id }" : '/search'
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
    respond_to :js
  end

  def search_page
    @records = current_user.records
    respond_to :js
  end
end
