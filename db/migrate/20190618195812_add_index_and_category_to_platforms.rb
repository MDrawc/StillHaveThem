class AddIndexAndCategoryToPlatforms < ActiveRecord::Migration[5.2]
  def change
    add_column :platforms, :category, :integer
    add_index :platforms, :igdb_id, unique: true
  end
end
