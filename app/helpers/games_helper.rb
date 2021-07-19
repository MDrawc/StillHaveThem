module GamesHelper
  def get_game_cover(game, width = 200)
    if cover = game[:cover]
      ratio = game[:cover_height]/game[:cover_width].to_f
      height = (width * ratio).round(2)
      cover_url = 'https://images.igdb.com/igdb/image/upload/t_cover_big_2x/'
      cover_url += cover.to_s + '.jpg'
      return { url: cover_url, width: width, height: height }
    elsif screenshots = game[:screenshots]
        base_url = 'https://images.igdb.com/igdb/image/upload/'
        url = base_url + 't_screenshot_med/' + screenshots.last + '.jpg'
        return { url: url, width: width, height: 266, from_scrn: 's-cover' }
    end
  end

  def get_game_thumb(game)
    if (cover = game[:cover]) || (screenshots = game[:screenshots])
      base_url = 'https://images.igdb.com/igdb/image/upload/t_thumb/'
      image_hash = cover ? (cover) : (screenshots.last)
      cover_url = base_url + image_hash + '.jpg'

      content_tag(:div, class: 'thumb-c') do
        concat image_tag('', id: "gt-#{ game[:igdb_id] }", class: "game-thumb", width: 70, height: 70, 'data-src' => cover_url, alt: game[:name], 'draggable' => 'false', 'uk-img' => '')
        concat content_tag(:div, '', class: 'shadow')
      end
    else
      content_tag(:div, svg('no_image_i') , class: 'no-thumb')
    end
  end

  def get_summary(game, f_max = 280, l_min = 50)
    if game[:summary]
      first, counter = [], 0
      words = game[:summary].scan(/[\S]+|\s/)

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

  def screens_urls(screens)
    urls = []
    screens.each do |screen|
      base_url = 'https://images.igdb.com/igdb/image/upload/'
      url_big = base_url + 't_original/' + screen + '.jpg'
      url_small = url_big.sub('original', 'screenshot_med')
      urls << { big: url_big, small: url_small }
    end
    return urls
  end

  def convert_status(status_id)
    status = [ nil,
      nil,
     'Alpha',
     'Beta',
     'Early Access',
     'Shut Down',
     'Cancelled',
     'Rumored']
    return status[status_id]
  end

  def convert_category(category_id)
    category = [ 'Main game',
      'DLC',
      'Expansion',
      'Bundle',
      'Standalone Expansion',
      'Mod',
      'Episode',
      'Season',
      'Remake',
      'Remaster',
      'Expanded Game',
      'Port',
      'Fork']
    return category[category_id]
  end
end
