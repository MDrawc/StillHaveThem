class Developer < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :developer_games
  has_many :games, through: :developer_games
end
