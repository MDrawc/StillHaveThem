
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

    content_tag(:div, nil, class: "game-cover-effect") do
      image_tag(cover_url, alt: game["name"], class: "game-cover",
       draggable: "false", width: options[:width])
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
end
