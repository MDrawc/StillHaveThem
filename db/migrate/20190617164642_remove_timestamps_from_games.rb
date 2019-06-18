class RemoveTimestampsFromGames < ActiveRecord::Migration[5.2]
  def change
    remove_timestamps :games
  end
end
