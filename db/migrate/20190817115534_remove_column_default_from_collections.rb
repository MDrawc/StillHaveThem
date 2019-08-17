class RemoveColumnDefaultFromCollections < ActiveRecord::Migration[5.2]
  def change
    remove_column :collections, :default, :boolean
  end
end
