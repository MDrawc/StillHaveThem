class RenameResultsToRecords < ActiveRecord::Migration[5.2]
  def self.up
    rename_table :results, :records
  end

  def self.down
    rename_table :records, :results
  end
end
