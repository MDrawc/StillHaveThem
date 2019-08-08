class Game < ApplicationRecord
  scope :igdb, -> (igdb_id) { where(igdb_id: igdb_id) }
  validates :name, presence: true
  validates :igdb_id, presence: true
  validates :platform, presence: { message: 'must be selected'}, if: :needs_platform?
  validates :platform, absence: { message: 'should not be indicated'}, unless: :needs_platform?

  has_many :collection_games
  has_many :collections, through: :collection_games

  has_many :developer_games
  has_many :developers, through: :developer_games

  ransack_alias :name_dev, :name_or_developers_name
  ransack_alias :plat, :platform_name

  def needs_platform
    needs_platform == true
  end

  amoeba do
    enable
    include_association :developer_games
  end
end
