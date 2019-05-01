class IgdbQuery
  include ActiveModel::Validations
  attr_accessor :name
  validates :name, presence: true, length: { minimum: 1 }

  def initialize(name)
    @name = name
  end


end
