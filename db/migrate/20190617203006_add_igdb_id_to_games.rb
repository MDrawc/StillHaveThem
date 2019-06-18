  class AddIgdbIdToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :igdb_id, :integer
  end
end
