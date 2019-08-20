module CollectionsHelper

  def create_initial_collections(user)
    initial_collections = [
      {name: 'My Collection', needs_platform: true },
      {name: 'Wishlist'},
      {name: 'I Have Played This'}
    ]

    user.collections.create(initial_collections)
  end

end
