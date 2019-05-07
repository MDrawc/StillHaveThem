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

  def status
      #refactor to use IgdbQuery class

      http = Net::HTTP.new('api-v3.igdb.com', 80)
      request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/api_status'),
       { 'user-key' => ENV['IGDB_KEY'] })

      request.body = "fields *;"
      @status = JSON.parse http.request(request).body
  end
end
