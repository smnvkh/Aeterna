class AddUserToFamilyMembers < ActiveRecord::Migration[8.1]
  def change
    add_reference :family_members, :user, null: true, foreign_key: true
  end
end
