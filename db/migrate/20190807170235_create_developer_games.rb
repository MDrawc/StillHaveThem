class CreateDeveloperGames < ActiveRecord::Migration[5.2]
  def change
    create_table :developer_games do |t|
      t.belongs_to :developer, index: true
      t.belongs_to :game, index: true
      t.timestamps
    end
  end
end
