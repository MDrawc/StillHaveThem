class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :name
      t.integer :first_release_date
      t.text :summary
      t.integer :status
      t.integer :category
      t.timestamps
    end
  end
end
