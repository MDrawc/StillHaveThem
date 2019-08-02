class AddResponseSizeToQueries < ActiveRecord::Migration[5.2]
  def change
    add_column :queries, :response, :integer
  end
end
