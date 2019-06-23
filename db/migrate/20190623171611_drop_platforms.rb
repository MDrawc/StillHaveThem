class DropPlatforms < ActiveRecord::Migration[5.2]
  def change
    drop_table :platforms
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
