class CreateCollectionGames < ActiveRecord::Migration[5.2]
  def change
    create_table :collection_games do |t|
      t.belongs_to :collection, index: true
      t.belongs_to :game, index:true
      t.timestamps
    end
  end
end
