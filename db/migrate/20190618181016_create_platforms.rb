class CreatePlatforms < ActiveRecord::Migration[5.2]
  def change
    create_table :platforms do |t|
      t.string :name
      t.string :abbreviation
      t.string :alternative_name
      t.text :summary
      t.integer :generation
      t.integer :igdb_id
      t.timestamps
    end
  end
end
