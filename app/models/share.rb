class Share < ApplicationRecord
  before_validation :prepare_shared
  before_validation :generate_token, on: :create
  belongs_to :user
  validates :token, presence: true
  validates :shared, presence: { message: 'You must select at least one collection' }
  validates :token, uniqueness: true
  validates :shared, uniqueness: { scope: :user_id,
    message: 'You already share this combination of collections' }
  validates :title, length: { maximum: 50 }
  validates :message, length: { maximum: 300 }
  default_scope { order(created_at: :desc) }

  def note_visit
    update(times_visited: times_visited + 1)
  end

  def last_visit
    updated_at == created_at ? false : updated_at
  end

  def title_or_message?
    !title.empty? || !message.empty?
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

