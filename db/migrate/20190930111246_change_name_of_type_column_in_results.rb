class ChangeNameOfTypeColumnInResults < ActiveRecord::Migration[5.2]
  def change
    rename_column :results, :type, :query_type
  end
end
