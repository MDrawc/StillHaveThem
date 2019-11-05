class Share < ApplicationRecord
  before_validation(on: :create) do
    prepare_shared
    generate_token
  end
  belongs_to :user
  validates :token, :shared, presence: true
  validates :token, uniqueness: true
  validates :shared, uniqueness: { scope: :user_id,
    message: "already shared" }
  validates :title, length: { maximum: 50 }
  validates :message, length: { maximum: 300 }
  default_scope { order(created_at: :desc) }

  def note_visit
    update(times_visited: times_visited + 1)
  end


  private

    def prepare_shared
      self.shared.compact!
      self.shared.sort!
    end

    def generate_token
      begin
        self.token = SecureRandom.urlsafe_base64(20, false)
      end while self.class.find_by(token: token)
    end
end

