class UserPlatform < ApplicationRecord
  belongs_to :user
  belongs_to :platform
  validates_uniqueness_of :platform_id, :scope => :user_id
end
