class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_games
  has_many :games, through: :collection_games
  scope :custom, -> { where(initial: false) }
  scope :initial, -> { where(initial: true) }
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 140 }

def called
  return (self.custom_name || self.name)
end

end
