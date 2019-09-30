class AddFiltersToResults < ActiveRecord::Migration[5.2]
  def change
    add_column :results, :filters, :string, array: true
  end
end
