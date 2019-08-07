class RemoveDevelopersFromGames < ActiveRecord::Migration[5.2]
  def change
    remove_column :games, :developers, :string, array: true
  end
end
