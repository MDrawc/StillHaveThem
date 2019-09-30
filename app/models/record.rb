class Record < ApplicationRecord
  RECORDS_LIMIT= 10
  belongs_to :user
  default_scope { order(updated_at: :desc) }

  validates :inquiry, presence: true
  validates :query_type, presence: true
  validates :query_type, inclusion: { in: ['game','char','dev'], message: 'is wrong' }
  validates :filters, presence: true
  validate :proper_filters_values
  validate :proper_number_of_filters

  before_save :maintain_records

  def proper_filters_values
    unless filters.map { |f| f == '1' || f == '0'}.all?
      errors.add(:filters, "has wrong values")
    end
  end

  def proper_number_of_filters
    unless filters.size == 15
      errors.add(:filters, "has wrong size")
    end
  end

  def maintain_records
    user = User.find(user_id)

    same_before = user.records.find_by(inquiry: inquiry,
     query_type: query_type,
     filters: filters)

    same_before.destroy if same_before

    if user.records.size >= RECORDS_LIMIT
      user.records.last.destroy
    end
  end
end
