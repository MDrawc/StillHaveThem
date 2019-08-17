module CollectionsHelper

  def create_initial_collections(user)
    initial_collections = [
      {name: 'My Collection', initial: true, needs_platform: true, form: 'collection'},
      {name: 'Wishlist', initial: true, form: 'wishlist'},
      {name: 'I Have Played This', initial: true, form: 'played'}
    ]

    user.collections.create(initial_collections)
  end

end
