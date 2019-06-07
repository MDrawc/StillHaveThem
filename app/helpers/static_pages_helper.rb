require 'net/https'

module StaticPagesHelper

  def get_game_cover(game, options = { width: 200 })
    cover = game["cover"]
    if cover.nil? || cover.class != Hash
      render partial: "no_cover", locals: { game: game }
    else
      cover_id = cover["image_id"]
      cover_url = 'https://images.igdb.com/igdb/image/upload/t_cover_big_2x/'
      cover_url += cover_id.to_s + ".jpg"
      render partial: "cover", locals: { game: game, cover_url: cover_url,
       options: options }
    end
  end

  def get_cover_url(game)
    cover = game["cover"]
    return nil if cover.nil? || cover.class != Hash
    cover_id = cover["image_id"]
    cover_url = 'https://images.igdb.com/igdb/image/upload/t_cover_big_2x/'
    cover_url += cover_id.to_s + ".jpg"
  end

  def get_summary(game, f_max, l_min)
    if game['summary']
      first, counter = [], 0
      words = game['summary'].scan(/[\S]+|\s/)

      while counter < f_max && !words.empty? do
        first << last = words.shift
        counter += last.size
      end

      if words.join.size < l_min
        first += words
        first = first.join.strip
        words, span = nil
      else
        first = first.join.strip
        span = first.last.scan(/[\.]/).present? ? '..' : '...'
        words = words.join.strip
      end

      return { start: first, span: span, end: words }
    else
      return false
    end
  end

  def get_screenshots(game)
    screenshots = game['screenshots']
    urls = []
    if screenshots && screenshots.class == Array
      if screenshots.any? { |thing| thing.class == Hash }

        filtered = screenshots.map { |thing| thing if thing.class == Hash }
        filtered = filtered.compact

        filtered.each do |screen|
          base_url = 'https://images.igdb.com/igdb/image/upload/'
          url_big = base_url + 't_original/' + screen['image_id'] + '.jpg'
          url_small = url_big.sub('original', 'screenshot_med')
          urls << {big: url_big, small: url_small}
        end
        return urls
      else
        return false
      end
    else
      return false
    end
  end

  def get_api_status

    http = Net::HTTP.new('api-v3.igdb.com', 80)
    request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/api_status'),
     { 'user-key' => ENV['IGDB_KEY'] })
    request.body = "fields *;"

    begin
      data = JSON.parse http.request(request).body
      data = data[0]["usage_reports"]["usage_report"]
      current = data["current_value"]
      max = data["max_value"]
      to_next_period = data["period_end"].to_date
      days_left = (to_next_period - Date.today).to_i
      requests_left = max - current
      status = requests_left > 0

      rescue JSON::ParserError
        days_left = "???"
        requests_left = "???"
        status = nil
    end

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
