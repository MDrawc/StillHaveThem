class AddResultsToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :results, :integer
  end
end
