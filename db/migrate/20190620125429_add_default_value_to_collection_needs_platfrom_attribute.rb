class AddDefaultValueToCollectionNeedsPlatfromAttribute < ActiveRecord::Migration[5.2]
  def change
    change_column :collections, :needs_platform, :boolean, default: false
  end
end
