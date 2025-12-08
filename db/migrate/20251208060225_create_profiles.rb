class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :avatar
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
