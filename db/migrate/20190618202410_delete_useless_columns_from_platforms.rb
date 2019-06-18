class DeleteUselessColumnsFromPlatforms < ActiveRecord::Migration[5.2]
  def change
    remove_column :platforms, :abbreviation, :string
    remove_column :platforms, :alternative_name, :string
    remove_column :platforms, :summary, :text
  end
end
