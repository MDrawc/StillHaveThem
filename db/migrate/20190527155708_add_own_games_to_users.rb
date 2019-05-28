class AddOwnGamesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :own_games, :boolean
  end
end
