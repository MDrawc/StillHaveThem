class AddThemsAndPlatformsCategoriesToAgames < ActiveRecord::Migration[5.2]
  def change
    add_column :agames, :themes, :integer, array: true
    add_column :agames, :platforms_categories, :integer, array: true
  end
end
