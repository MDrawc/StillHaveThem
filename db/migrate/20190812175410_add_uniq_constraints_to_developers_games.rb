class AddUniqConstraintsToDevelopersGames < ActiveRecord::Migration[5.2]
  def change
    add_index :developer_games, [:developer_id, :game_id], unique: true
  end
end
