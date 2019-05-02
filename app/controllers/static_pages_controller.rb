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
    end
  end
end
