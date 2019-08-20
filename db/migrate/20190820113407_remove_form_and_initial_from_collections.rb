class RemoveFormAndInitialFromCollections < ActiveRecord::Migration[5.2]
  def change
    remove_column :collections, :initial, :boolean, default: false
    remove_column :collections, :form, :string, default: 'custom'
  end
end
