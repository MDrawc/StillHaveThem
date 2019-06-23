class AddInitialAndFormColumnsToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :form, :string, default: 'custom'
    add_column :collections, :initial, :boolean, default: 'false'
  end
end
