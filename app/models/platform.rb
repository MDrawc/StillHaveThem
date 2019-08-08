class Platform < ApplicationRecord
validates :name, presence: true, uniqueness: true
validates :igdb_id, presence: true, uniqueness: true

has_many :user_platforms
has_many :users, through: :user_platforms
end
