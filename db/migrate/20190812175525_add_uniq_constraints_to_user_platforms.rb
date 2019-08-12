class AddUniqConstraintsToUserPlatforms < ActiveRecord::Migration[5.2]
  def change
    add_index :user_platforms, [:platform_id, :user_id], unique: true
  end
end
