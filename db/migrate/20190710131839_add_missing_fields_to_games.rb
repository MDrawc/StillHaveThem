class AddMissingFieldsToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :developers, :string, array: true, default: []
    add_column :games, :cover, :string
    add_column :games, :screenshots, :string, array: true, default: []
  end
end
