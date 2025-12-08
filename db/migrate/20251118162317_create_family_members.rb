class CreateFamilyMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :family_members do |t|
      t.string :name
      t.string :relation
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
