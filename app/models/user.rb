class User < ApplicationRecord
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
end
