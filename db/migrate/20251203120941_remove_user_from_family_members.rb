class RemoveUserFromFamilyMembers < ActiveRecord::Migration[8.1]
  def change
    remove_reference :family_members, :user, null: false, foreign_key: true
  end
end
