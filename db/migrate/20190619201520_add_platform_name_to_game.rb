class AddPlatformNameToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :platform_name, :string
  end
end
