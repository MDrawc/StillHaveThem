module CollectionsHelper

def create_default_collections(user)
  user.collections.create(name: 'My Collection', default: true)
  user.collections.create(name: 'Wishlist', default: true)
  user.collections.create(name: 'I Have Played This', default: true)
end

end
