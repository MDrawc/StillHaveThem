class AddGamesPerViewsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :games_per_view, :integer, default: 30
  end
end
