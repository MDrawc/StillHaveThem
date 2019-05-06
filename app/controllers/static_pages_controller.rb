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

      #refactor this

    elsif params[:last_query]

      @inquiry = IgdbQuery.new(params[:last_query],
                 params[:last_offset].to_i + IgdbQuery::RESULT_LIMIT)

      @inquiry.search
      sm_id = "sm-#{ params[:last_offset].to_i / IgdbQuery::RESULT_LIMIT}"

      respond_to do |format|
        format.js { render partial: "search_more", locals: { sm_id: sm_id } }
      end
    end
  end
end
