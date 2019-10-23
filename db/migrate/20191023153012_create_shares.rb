class CreateShares < ActiveRecord::Migration[5.2]
  def change
    create_table :shares do |t|
      t.references :user
      t.string :key
      t.integer :shared, array: true
      t.integer :times_visited
      t.timestamps
    end
  end
end
