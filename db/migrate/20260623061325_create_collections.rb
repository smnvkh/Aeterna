class CreateCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :collections do |t|
      t.string :title
      t.date :date
      t.references :family, null: false, foreign_key: true
      t.references :family_member, null: true, foreign_key: true

      t.timestamps
    end
  end
end
