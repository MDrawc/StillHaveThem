class CreateUserPlatforms < ActiveRecord::Migration[5.2]
  def change
    create_table :user_platforms do |t|
      t.belongs_to :user, index: true
      t.belongs_to :platform, index: true
      t.timestamps
    end
  end
end
