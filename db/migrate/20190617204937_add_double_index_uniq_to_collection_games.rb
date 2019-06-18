class AddDoubleIndexUniqToCollectionGames < ActiveRecord::Migration[5.2]
  def change
    add_index :collection_games, [:collection_id, :game_id], unique: true
  end
end
