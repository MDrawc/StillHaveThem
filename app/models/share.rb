class Share < ApplicationRecord
  before_validation { shared.sort! }
  belongs_to :user
  validates :key, :shared, presence: true
  validates :shared, uniqueness: { scope: :user_id,
    message: "already shared" }

  def note_visit
    update(times_visited: times_visited + 1)
  end
end

