class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_games, dependent: :destroy
  has_many :games, through: :collection_games
  default_scope { order(cord: :asc) }
  validates :user_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :user_id,
    message: "is used by another collection", case_sensitive: false }, length: { maximum: 30 }

  GAMES_PER_PAGE_SHARED = 30

  def is_shared?()
    !user.shares.where('? = ANY(shared)', id).empty?
  end
end
