class CreateAgames < ActiveRecord::Migration[5.2]
  def change
    create_table :agames do |t|
      t.integer :igdb_id, index: true
      t.string :name
      t.integer :first_release_date
      t.text :summary
      t.integer :status
      t.integer :category
      t.string :cover
      t.integer :platforms, default: [], array: true
      t.string :platforms_names, default: [], array: true
      t.string :developers, default: [], array: true
      t.string :screenshots, default: [], array: true
      t.timestamps
    end
  end
end
