require 'net/https'

module StaticPagesHelper

  def get_game_cover(game, options = { width: 200 })
    cover = game["cover"]
    if cover.nil? || cover.class != Hash
      no_cover = content_tag(:div, content_tag(:p, game["name"] ,
        class: "no-cover-tag unselectable"), class: "no-cover")
      return no_cover
    end
    cover_id = cover["image_id"]
    cover_url = 'https://images.igdb.com/igdb/image/upload/t_cover_big_2x/'
    cover_url += cover_id.to_s + ".jpg"

    render partial: "cover", locals: { game: game, cover_url: cover_url, options: options}
  end

  def get_api_status
    # http = Net::HTTP.new('api-v3.igdb.com', 80)
    # request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/api_status'),
    #  { 'user-key' => ENV['IGDB_KEY'] })

    # request.body = "fields *;"
    # data = JSON.parse http.request(request).body
    # data = data[0]["usage_reports"]["usage_report"]
    # current = data["current_value"]
    # max = data["max_value"]
    # to_next_period = data["period_end"].to_date
    # days_left = (to_next_period - Date.today).to_i
    # requests_left = max - current
    # status = requests_left > 0

    days_left = 0
    requests_left = 0
    status = requests_left > 0

    [status, requests_left, days_left]
  end

  def convert_status(status_id)
    status = [ nil,
      nil,
     'in alpha state',
     'in beta state',
     'in early access',
     'game or/and online modes are shut down',
     'cancelled']
    return status[status_id]
  end

  def convert_category(category_id)
    category = [ 'main game',
      'DLC addon',
      'Expansion',
      'Bundle',
      'Standalone expansion']
    return category[category_id]
  end
end
