class Query < ApplicationRecord
validates :endpoint, presence: true
validates :body, presence: true, uniqueness: { scope: :endpoint,
    message: "only one body per endpoint allowed" }
end
