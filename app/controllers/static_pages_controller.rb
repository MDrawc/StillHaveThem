class StaticPagesController < ApplicationController

  def home
  end

  def about
  end

  def search
    if params[:inquiry]
      @inquiry = IgdbQuery.new(params[:inquiry])
      @inquiry.search

      respond_to do |format|
        format.js
      end

    elsif params[:last_query]
      @inquiry = IgdbQuery.new(params[:last_query],
                 params[:last_offset].to_i + IgdbQuery::RESULT_LIMIT)
      @inquiry.search

      respond_to do |format|
        format.js { render partial: "show_more" }
      end
    end
  end
end
