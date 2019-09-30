class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.string :inquiry
      t.string :type

      t.timestamps
    end
  end
end
