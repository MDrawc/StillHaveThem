class StaticPagesController < ApplicationController
  # For duplicates removal:
  @@last_result_ids = []

  def home
  end

  def about
  end

  def search
    # First time search:
    if params[:search]
      @inquiry = IgdbQuery.new(params[:search])

      if @inquiry.validate!
        @inquiry.search
        @@last_result_ids = @inquiry.results.map { |game| game = game["id"] }
      end

      respond_to do |format|
        format.js
      end
    # Load more:
    elsif params[:last_input]
      @inquiry = IgdbQuery.new(eval(params[:last_input]),
                 params[:last_offset].to_i + IgdbQuery::RESULT_LIMIT)
      @inquiry.search
      @inquiry.fix_duplicates(@@last_result_ids)
      @@last_result_ids += @inquiry.results.map { |game| game = game["id"] }

      respond_to do |format|
        format.js { render partial: "show_more" }
      end
    end
  end

  def status
    # Make helper for this:
    http = Net::HTTP.new('api-v3.igdb.com', 80)
    request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/api_status'),
     { 'user-key' => ENV['IGDB_KEY'] })

    request.body = "fields *;"
    @status = JSON.parse http.request(request).body
  end

  def test

  end
end
