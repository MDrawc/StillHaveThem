class AddIndexToNameInDevelopers < ActiveRecord::Migration[5.2]
  def change
    add_index :developers, :name, unique: true
  end
end
