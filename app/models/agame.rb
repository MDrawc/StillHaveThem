class Agame < ApplicationRecord
  validates :name, presence: true
  validates :igdb_id, presence: true, uniqueness: true

  def data_for_adding
    attributes.slice('id',
       'igdb_id',
        'name',
         'platforms',
          'platforms_names').symbolize_keys
  end
end
