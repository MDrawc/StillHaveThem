class StaticPagesController < ApplicationController

  def home
  end

  def about
  end

  def search
    @search = IgdbQuery.new("")
    if params[:inquiry]
      @search = IgdbQuery.new(params[:inquiry])
      if @search.valid?
        @search.request
      else
        render 'search'
      end
      respond_to do |format|
        format.js
      end
    elsif params[:last_query]
      @search = IgdbQuery.new(params[:last_query])
      @search.get_more

      respond_to do |format|
        format.js { render :partial => "search_more" }
      end
    end
  end
end
