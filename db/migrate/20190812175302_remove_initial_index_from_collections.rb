class RemoveInitialIndexFromCollections < ActiveRecord::Migration[5.2]
  def change
    remove_index :collections, :initial
  end
end
