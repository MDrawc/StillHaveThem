class StaticPagesController < ApplicationController

  def home
  end

  def about
  end

  def search
    if params[:inquiry]
      api_endpoint = 'https://api-v3.igdb.com/games'
      request_headers = { headers: { 'user-key' => ENV['IGDB_KEY'] } }
      api = Apicalypse.new(api_endpoint, request_headers)
        .fields(:name, :first_release_date)
        .limit(50)
        .offset(0)
        .search(params[:inquiry])

      @search_results = api.request
      @search_results.map { |game|
        (release_date = game['first_release_date']) ?
        game['first_release_date'] = Time.at(release_date).year
         : game['first_release_date'] = ' - ' }

      respond_to do |format|
        format.js
      end
    end
  end
end
