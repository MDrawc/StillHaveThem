class RemoveColumnCustomNameFromCollections < ActiveRecord::Migration[5.2]
  def change
    remove_column :collections, :custom_name, :string
  end
end
