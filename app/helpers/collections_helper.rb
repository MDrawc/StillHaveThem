module CollectionsHelper
  def user_platforms
    current_user.platforms_names
  end

  def guest_platforms
    guest.platforms_names
  end

  def collections_for_select
    current_user.collections_for_select
  end

  def platforms_for_select(game)
    ids = game[:platforms]
    platforms = []
    game[:platforms_names].each_with_index do |nm, i|
      platforms << [ nm, "#{ ids[i] },#{ nm }"]
    end
    return platforms
  end
end



