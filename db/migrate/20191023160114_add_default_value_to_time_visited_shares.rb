class AddDefaultValueToTimeVisitedShares < ActiveRecord::Migration[5.2]
  def change
    change_column_default :shares, :times_visited, 0
  end
end
