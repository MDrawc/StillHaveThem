class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_games
  has_many :games, through: :collection_games
  default_scope -> { order(created_at: :asc) }
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 140 }
end
