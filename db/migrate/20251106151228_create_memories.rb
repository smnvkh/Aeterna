class CreateMemories < ActiveRecord::Migration[8.1]
  def change
    create_table :memories do |t|
      t.string :title
      t.string :author
      t.text :body
      t.date :date
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
