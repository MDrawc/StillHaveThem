class Share < ApplicationRecord
  before_validation { shared.sort! }
  belongs_to :user
  validates :key, :shared, presence: true
  validates :shared, uniqueness: { scope: :user_id,
    message: "already shared" }
end
