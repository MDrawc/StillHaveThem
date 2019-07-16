class AddAddlColumnToQueries < ActiveRecord::Migration[5.2]
  def change
    add_column :queries, :addl, :string, array: true
  end
end
