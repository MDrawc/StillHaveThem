# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#My user:
user = User.new
user.email = 'pistolisloaded@gmail.com'
user.password = 'andy21'
user.save!

user.collections.create(name: 'My Collection', default: true, initial: true, needs_platform: true, form: 'collection')
user.collections.create(name: 'Wishlist', default: false, initial: true, form: 'wishlist')
user.collections.create(name: 'I\'ve Played This', default: false, initial: true, form: 'played')

#My extra user
user = User.new
user.email = 'nakedtingle@gmail.com'
user.password = 'andy21'
user.save!

user.collections.create(name: 'My Collection', default: true, initial: true, needs_platform: true, form: 'collection')
user.collections.create(name: 'Wishlist', default: false, initial: true, form: 'wishlist')
user.collections.create(name: 'I\'ve Played This', default: false, initial: true, form: 'played')
