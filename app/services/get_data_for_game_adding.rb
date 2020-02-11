class GetDataForGameAdding < ApplicationService
  def initialize(x_id:)
    @x_id = x_id
  end

  def call
    get_igdb_id_from_x_id(@x_id)
    get_data_from_agame
  end

  private
    def get_igdb_id_from_x_id(x_id)
      if x_id.include?('-')
        hex_size = SearchIgdb::SR_HEX
        @igdb_id = x_id.slice(0..-(2 * hex_size + 1))
      else
        @igdb_id = x_id
      end
    end

    def get_data_from_agame
      data = Agame.find_by(igdb_id: @igdb_id).data_for_add_form
    end
end

