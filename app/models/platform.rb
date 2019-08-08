class Platform < ApplicationRecord
validates :name, presence: true
validates :igdb_id, presence: true

has_many :user_platforms
has_many :users, through: :user_platforms
end
