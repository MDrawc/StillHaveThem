class AddIndexesToCollectionGamesAndGames < ActiveRecord::Migration[5.2]
  def change
    add_index :collection_games, [:collection_id, :game_id, :created_at], name: 'by_coll_game_created_at'
    add_index :games, [:igdb_id, :needs_platform]
    add_index :platforms, :igdb_id, unique: true
  end
end
