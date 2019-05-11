class StaticPagesController < ApplicationController

  def home
  end

  def about
  end

  def search
    if params[:search]
      # debugger
      @inquiry = IgdbQuery.new(params[:search])
      @inquiry.search

      respond_to do |format|
        format.js
      end

    elsif params[:last_input]
      @inquiry = IgdbQuery.new(eval(params[:last_input]),
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
