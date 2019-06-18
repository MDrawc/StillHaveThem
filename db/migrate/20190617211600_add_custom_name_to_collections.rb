class AddCustomNameToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :custom_name, :string
  end
end
