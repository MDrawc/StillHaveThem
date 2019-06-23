module CollectionsHelper

def create_default_collections(user)
  user.collections.create(name: 'My Collection', default: true, form: 'collection')
  user.collections.create(name: 'Wishlist', default: true, form: 'wishlist')
  user.collections.create(name: 'I Have Played This', default: true, form: 'played')
end

end
