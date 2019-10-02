class AddCustomFiltersToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :custom_filters, :boolean
  end
end
