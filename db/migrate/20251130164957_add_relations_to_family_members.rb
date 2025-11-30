class AddRelationsToFamilyMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :family_members, :mother_id, :integer
    add_column :family_members, :father_id, :integer
    add_column :family_members, :spouse_id, :integer
    add_column :family_members, :gender, :string
  end
end
