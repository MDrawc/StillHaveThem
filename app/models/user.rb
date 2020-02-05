class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_create :create_activation_digest
  before_save { email.downcase! }

  has_many :collections, dependent: :destroy
  has_many :user_platforms, dependent: :destroy
  has_many :platforms, through: :user_platforms
  has_many :records, dependent: :destroy
  has_many :shares, dependent: :destroy

  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
   format: { with: VALID_EMAIL_FORMAT }, uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  validates :games_per_view, inclusion: { in: (5..50).to_a }

  def gpv
    games_per_view
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def authenticated?(attribute, token)
    digest = send("#{ attribute }_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def deactivate_and_send_new
    self.deactivate
    self.new_activation_digest
    self.send_reactivation_email
  end

  def deactivate
    update_columns(activated: false, activated_at: nil)
  end

  def create_initial_collections
    initial_collections = [
      {name: 'Main Collection', needs_platform: true, cord: 1 },
      {name: 'Wishlist', cord: 2 }
    ]

    collections.create(initial_collections)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_reactivation_email
    UserMailer.email_confirmation(self).deliver_now
  end

  def new_activation_digest
      self.activation_token = User.new_token
      self.update_attribute(:activation_digest, User.digest(activation_token))
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
