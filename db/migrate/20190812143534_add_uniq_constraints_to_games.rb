class AddUniqConstraintsToGames < ActiveRecord::Migration[5.2]
  def change
    remove_index :games, :igdb_id
    add_index :games, [:igdb_id, :platform, :physical], unique: true
  end
end
