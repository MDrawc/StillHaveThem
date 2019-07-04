class AddIndexInitialToCollections < ActiveRecord::Migration[5.2]
  def change
    add_index :collections, :initial
  end
end
