class RemoveOwnGamesFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :own_games
  end
end
