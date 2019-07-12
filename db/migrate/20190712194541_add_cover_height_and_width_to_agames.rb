class AddCoverHeightAndWidthToAgames < ActiveRecord::Migration[5.2]
  def change
    add_column :agames, :cover_width, :integer
    add_column :agames, :cover_height, :integer
  end
end
