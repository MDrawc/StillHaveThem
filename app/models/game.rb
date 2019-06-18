class Game < ApplicationRecord
  validates :name, presence: true

  has_many :collection_games
  has_many :collections, through: :collection_games
end
