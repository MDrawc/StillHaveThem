class AddIndexToGames < ActiveRecord::Migration[5.2]
  def change
    add_index :games, :igdb_id
  end
end
