class StaticPagesController < ApplicationController

  def home
  end

  def about
  end

  def search
    if params[:inquiry]
      @search_results = GameQuery.new(params[:inquiry]).results
      respond_to do |format|
        format.js
      end
    end
  end
end
