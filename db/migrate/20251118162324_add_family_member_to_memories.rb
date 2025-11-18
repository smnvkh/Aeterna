class AddFamilyMemberToMemories < ActiveRecord::Migration[8.1]
  def change
    add_reference :memories, :family_member, foreign_key: true
  end
end
