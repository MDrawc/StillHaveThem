class AddPlatformToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :platform, :integer
  end
end
