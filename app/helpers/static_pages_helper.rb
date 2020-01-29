require 'net/https'

module StaticPagesHelper

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

  def get_summary(game, f_max, l_min)
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
     'Alpha state',
     'Beta state',
     'Early access',
     'Shut down',
     'Cancelled']
    return status[status_id]
  end

  def convert_category(category_id)
    category = [ 'Main game',
      'DLC',
      'Expansion',
      'Bundle',
      'Standalone expansion',
      'Mod',
      'Episode']
    return category[category_id]
  end

  def platforms_for_select(game)
    ids = game[:platforms]
    platforms = []
    game[:platforms_names].each_with_index do |nm, i|
      platforms << [ nm, "#{ ids[i] },#{ nm }"]
    end
    return platforms
  end

  def user_platforms
    current_user.platforms.map(&:name)
  end

  def guest_platforms
    User.find_by_id(guest.user_id).platforms.map(&:name)
  end

  def user_platforms_for_select
    current_user.platforms.map { |p| [p.name, "#{ p.igdb_id },#{ p.name }"]}
  end

  def colls_graph_form(user)
    if user.class.name == 'User'
      [['Overall', 'all']] + current_user.collections.collect { |c| [c.name, c.id] }
    else
      shared_colls = Collection.where(id: user.shared)
      [['All Shared', 'all']] + shared_colls.collect { |c| [c.name, c.id] }
    end
  end

  def collections_for_select(user)
    user.collections.collect { |c| [ c.name, "#{c.id},#{c.needs_platform}" ] }
  end

  def check_for_games(options = {})
    collections = current_user.collections.includes(:games)
    # collections = collections.sort_by { |c| [c.needs_platform ? 1 : 0] }
    id = options[:game_id] || options[:igdb_id]

    results = {}

    collections.each do |collection|
      games = collection.games
      findings = options[:igdb_id] ? games.igdb(id) : games.find_by_id(id)
      results[collection] = findings if findings.present?
    end

    return results.empty? ? false : results
  end

  def present_bar_record(record)
    type = record.query_type

    case type
    when 'game' then endpoint = 'game'
    when 'char' then endpoint = 'character'
    when 'dev' then  endpoint = 'developer'
    end

    ago = time_ago_in_words(record.created_at) + ' ago'

    results = pluralize(record.results, 'result')

    results += ' (filters)' if record.custom_filters

    results = results.sub('50', '50+')

    extr = ago + content_tag(:span, results)

    unless custom = record.custom_filters
      content_tag(:div, class: 'record', 'e': type, 'i': record.inquiry, 'cf': custom) do
        concat endpoint
        concat content_tag :span, record.inquiry, class: 'input uk-text-truncate'
        concat content_tag :div, extr.html_safe, class: 'extr'
      end
    else
      content_tag(:div, class: 'record', 'e': type, 'i': record.inquiry, 'cf': custom, 'f': record.filters) do
        concat endpoint
        concat content_tag :span, record.inquiry, class: 'input uk-text-truncate'
        concat content_tag :div, extr.html_safe, class: 'extr'
      end
    end
  end

  def get_colors(number, theme = :default)
    paletts = { default: {
      0 => nil,
      1 => ["#49AB8A"],
      2 => ["#49AB8A", "#ab496a"],
      3 => ["#49AB8A", "#ab8a49", "#8a49ab"],
      4 => ["#49AB8A", "#ab496a", "#ab8a49", "#496aab"],
      5 => ["#49ab8a", "#ab496a", "#8a53b7", "#b1b750", "#6f6d72"],
      10 => ["#49ab8a", "#ab496a", "#684bbc", "#8dcf53", "#473252", "#ccae61", "#cc58c0", "#565635", "#9da5c5", "#c55536"],
      12 => ["#49ab8a", "#ab496a", "#7bcf55", "#6943b9", "#c9ba51", "#442d49", "#99c8c8", "#c55434", "#8589c2", "#cf56bd", "#535731", "#cb9e8d"],
      20 => ["#67b292", "#7347d8", "#5abb49", "#cd4ece", "#a9ac3c", "#6e369c",
           "#d7893b", "#6a7dd3", "#d7493c", "#75a8c4", "#d34586", "#497132",
           "#c484c4", "#ad9764", "#5e3e7c", "#8b472a", "#475a75", "#c98e95",
           "#53543f", "#81384f"],
      30 => ["#974028", "#7343d4", "#73ca45", "#cf4ed1", "#638b2c", "#4c298e",
           "#c8b63c", "#717edf", "#df502b", "#68c886", "#d94391", "#407644",
           "#963d91", "#b7b780", "#474a8d", "#d78d48", "#4e2554", "#70c3b9",
           "#d7415a", "#7fb0d7", "#5a2d28", "#cc90d5", "#374023", "#d47a91",
           "#507d77", "#8b3554", "#866e3e", "#6e7297", "#c69e9c", "#353d4d"]
      },
      dark: {
      0 => nil,
      1 => ["#5759a9"],
      2 => ["#5759a9", "#ca5d9d"],
      3 => ["#5759a9", "#ca5d9d", "#98964a"],
      4 => ["#5759a9", "#ca5d9d", "#ca6d42", "#78a353"],
      5 => ["#5759a9", "#ca5d9d", "#b263cd", "#78a353", "#ca6d42"],
      10 => ["#5759a9", "#ca5d9d", "#739cdb", "#69a742", "#b261cc", "#4ea982",
            "#d04046", "#a5933e", "#c76a71", "#cc793a"],
      12 => ["#5759a9", "#ca5d9d", "#78bf4b", "#9c4bc4", "#70bf99", "#d54c3e",
            "#5f9fc8", "#b4784b", "#557037", "#c996c8", "#cdac47", "#964454"],
      20 => ["#7347d8", "#67b292", "#cd4ece", "#5abb49", "#a9ac3c", "#6e369c",
           "#d7893b", "#6a7dd3", "#d7493c", "#75a8c4", "#d34586", "#497132",
           "#c484c4", "#ad9764", "#5e3e7c", "#8b472a", "#475a75", "#c98e95",
           "#53543f", "#81384f"],
      30 => ["#974028", "#7343d4", "#73ca45", "#cf4ed1", "#638b2c", "#4c298e",
           "#c8b63c", "#717edf", "#df502b", "#68c886", "#d94391", "#407644",
           "#963d91", "#b7b780", "#474a8d", "#d78d48", "#4e2554", "#70c3b9",
           "#d7415a", "#7fb0d7", "#5a2d28", "#cc90d5", "#374023", "#d47a91",
           "#507d77", "#8b3554", "#866e3e", "#6e7297", "#c69e9c", "#353d4d"]
      }
    }
    max_key = paletts[theme].keys.max
    if paletts[theme].include?(number)
      paletts[theme][number]
    elsif number < max_key
      paletts[theme].each do |k, v|
        return v[0...number] if k > number
      end
    else
      result = paletts[theme][max_key]
      (number - max_key).times { result.append "##{ random_color(rand(0.1..0.95),rand(0.3..0.8)) }" }
      return result
    end
  end

  def random_color(sat, light)
    generator = ColorGenerator.new saturation: sat, lightness: light
    color = generator.create_hex
  end
end



