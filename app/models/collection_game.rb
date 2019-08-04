class CollectionGame < ApplicationRecord
  belongs_to :collection
  belongs_to :game, inverse_of: :collection_games
  default_scope { order(created_at: :desc) }
end
