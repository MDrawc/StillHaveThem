class StaticPagesController < ApplicationController

  def home
  end

  def about
  end

  def search
    if (inquiry = params[:inquiry])

      api_endpoint = 'https://api-v3.igdb.com/games'
      request_headers = { headers: { 'user-key' => '605c81028ed48d0b6ee68e29dd247b75' } }

      api = Apicalypse.new(api_endpoint, request_headers)
      api
        .fields(:name, :first_release_date)
        .search(params[:inquiry])
        .limit(50)
        .offset(0)

      @search_results = api.request
      @search_results.map { |game|
        (release_date = game['first_release_date']) ?
        game['first_release_date'] = Time.at(1317686400).year
         : game['first_release_date'] = ' - ' }
    end
  end

end
