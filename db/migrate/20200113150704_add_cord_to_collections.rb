class AddCordToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :cord, :integer
    add_index :collections, :cord, unique: true
  end
end
