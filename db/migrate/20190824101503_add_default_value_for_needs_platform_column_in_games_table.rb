class AddDefaultValueForNeedsPlatformColumnInGamesTable < ActiveRecord::Migration[5.2]
  def change
    change_column :games, :needs_platform, :boolean, default: false
  end
end
