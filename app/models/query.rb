class Query < ApplicationRecord
validates :body, uniqueness: { scope: :endpoint,
    message: "only one body per endpoint allowed" }
end
