class AddColumnsToGamesAndCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :physical, :boolean
    add_column :games, :needs_platform, :boolean
    add_column :collections, :needs_platform, :boolean
  end
end
