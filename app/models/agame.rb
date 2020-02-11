class Agame < ApplicationRecord
  validates :name, presence: true
  validates :igdb_id, presence: true, uniqueness: true

  def data_for_add_form
    attributes.slice('id',
       'igdb_id',
        'name',
         'platforms',
          'platforms_names').symbolize_keys
  end

  def data_for_game_creation
    attributes.except('id',
                      'created_at',
                      'updated_at',
                      'themes',
                      'developers',
                      'platforms_categories')
  end
end
