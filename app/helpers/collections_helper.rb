module CollectionsHelper

  def create_initial_collections(user)
    initial_collections = [
      {name: 'Main Collection', needs_platform: true, cord: 1 },
      {name: 'Wishlist', cord: 2 }
    ]

    user.collections.create(initial_collections)
  end

end
