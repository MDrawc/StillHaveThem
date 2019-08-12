class AddPartialUniqIndexToGames < ActiveRecord::Migration[5.2]
  def change
    add_index :games, :igdb_id, unique: true, where: "platform is null AND physical is null"
  end
end
