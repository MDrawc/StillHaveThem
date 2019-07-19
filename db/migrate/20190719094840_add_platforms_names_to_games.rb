class AddPlatformsNamesToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :platforms_names, :string, array: true
  end
end
