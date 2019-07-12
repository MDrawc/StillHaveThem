class CreateQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :queries do |t|
      t.string :endpoint, index: true
      t.string :body, index: true
      t.integer :results, default: [], array: true
      t.timestamps
    end
  end
end
