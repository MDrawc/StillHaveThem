require 'net/https'

module StaticPagesHelper

  def get_game_cover(game, width = 200)
    cover = game["cover"]
    if cover.nil? || cover.class != Hash
      screenshots = game['screenshots']
      if screenshots && screenshots.class == Array
        if screenshots.first.class == Hash
          base_url = 'https://images.igdb.com/igdb/image/upload/'
          url = base_url + 't_screenshot_med/' + screenshots.first['image_id'] + '.jpg'
          return { url: url, width: width, height: 266, from_scrn: 's-cover' }
        end
      end
    else
      ratio = cover["height"]/cover["width"].to_f
      height = (width * ratio).round(2)
      cover_url = 'https://images.igdb.com/igdb/image/upload/t_cover_big_2x/'
      cover_url += cover["image_id"].to_s + ".jpg"
      return { url: cover_url, width: width, height: height }
    end
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

  def get_developer(game)
    involved = game['involved_companies']
    if involved && involved.class == Array
      if involved.any? { |thing| thing.class == Hash }
        devs = []
        involved.each do |company|
          devs << company['company']['name'] if company['developer']
        end
        return devs if devs.present?
      end
    elsif game['request'] == :dev
      return [game['xtra']]
    end
    return false
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

  def scalp_platforms(game, key = 'id')
    game['platforms'].collect { |platform| platform[key] }
  end

  def platforms_for_select(game)
    game['platforms'].collect { |p| [ p['name'], "#{p['id']},#{p['name']}" ] }
  end

  def collections_for_select(user)
    user.collections.custom.collect { |c| [ c.custom_name, "#{c.id},#{c.needs_platform}" ] }
  end

  def check_for_games(options = {})

    collections = current_user.collections

    id = options[:game_id] || options[:igdb_id]

    case options[:type]
    when 'initial'; collections = collections.initial
    when 'custom'
      collections = collections.custom.sort_by { |c| [c.needs_platform ? 1 : 0] }
    end

    results = {}

    collections.each do |collection|
      games = collection.games
      findings = options[:igdb_id] ? games.igdb(id) : games.find_by_id(id)
      results[collection] = findings if findings.present?
    end

    return results.present? ? results : false
  end

  def collection_initial(collection)
    name = collection.custom_name || collection.name
    return name.first.capitalize
  end
end

