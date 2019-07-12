class AddCoverWidthAndHeightColumnsToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :cover_width, :integer
    add_column :games, :cover_height, :integer
  end
end
