class ChangeIndexesInQueries < ActiveRecord::Migration[5.2]
  def change
    remove_index :queries, :body
    remove_index :queries, :endpoint
    add_index :queries, [:endpoint, :body], unique: true
  end
end
