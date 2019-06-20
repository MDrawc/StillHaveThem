class Game < ApplicationRecord
  validates :name, presence: true
  validates :platform, presence: true, if: :needs_platform?

  has_many :collection_games
  has_many :collections, through: :collection_games

  def needs_platform
    needs_platform == true
  end
end
