require 'apicalypse'

module StaticPagesHelper
  def getino(id)
    api_endpoint = 'https://api-v3.igdb.com/games'
    request_headers = { headers: { 'user-key' => '605c81028ed48d0b6ee68e29dd247b75' } }

    api = Apicalypse.new(api_endpoint, request_headers)

    api
      .fields(:name)
      .where("id = #{id}")
      .limit(5)

    api.request
  end

  def get_cover(game_id, thumb_size = false)
    api_endpoint = 'https://api-v3.igdb.com/covers'
    request_headers = { headers: { 'user-key' => '605c81028ed48d0b6ee68e29dd247b75' } }
    api = Apicalypse.new(api_endpoint, request_headers)
    api
      .fields(:image_id)
      .where("game = #{game_id}")
    cover_url = 'https://images.igdb.com/igdb/image/upload/'
    cover_url += thumb_size ? 't_thumb/' : 't_cover_big/'
    cover_url += api.request.first['image_id'] + '.jpg'
    image_tag(cover_url, alt: game_id, class: 'gamecover')
  end

  def get_thumb(game_id)
    get_cover(game_id, true)
  end
end
