class DeleteGenerationFromPlatforms < ActiveRecord::Migration[5.2]
  def change
    remove_column :platforms, :generation, :integer
  end
end
