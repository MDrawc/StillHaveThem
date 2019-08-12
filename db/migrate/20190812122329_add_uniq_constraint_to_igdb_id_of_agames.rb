class AddUniqConstraintToIgdbIdOfAgames < ActiveRecord::Migration[5.2]
  def change
   remove_index :agames, :igdb_id
   add_index :agames, :igdb_id, unique: true
  end
end
