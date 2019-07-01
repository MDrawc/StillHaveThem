class Game < ApplicationRecord
  scope :igdb, -> (igdb_id) { where(igdb_id: igdb_id) }
  validates :name, presence: true
  validates :platform, presence: { message: 'must be selected'}, if: :needs_platform?
  validates :platform, absence: { message: 'should not be indicated'}, unless: :needs_platform?

  has_many :collection_games
  has_many :collections, through: :collection_games

  def needs_platform
    needs_platform == true
  end
end
