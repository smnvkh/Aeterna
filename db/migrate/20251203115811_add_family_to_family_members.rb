class AddFamilyToFamilyMembers < ActiveRecord::Migration[8.1]
  def change
    add_reference :family_members, :family, null: false, foreign_key: true
  end
end
