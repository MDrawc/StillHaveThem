class ChangeSharesTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :shares, :key, :token
    add_index :shares, :token, unique: true
    add_column :shares, :title, :string
    add_column :shares, :message, :text
  end
end
