class AddPlatformsToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :platforms, :integer, array: true, default: []
  end
end
