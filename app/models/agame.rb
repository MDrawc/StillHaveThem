class Agame < ApplicationRecord
  validates :name, presence: true
  validates :igdb_id, presence: true, uniqueness: true
end
