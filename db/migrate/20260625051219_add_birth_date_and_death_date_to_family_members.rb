class AddBirthDateAndDeathDateToFamilyMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :family_members, :birth_date, :date
    add_column :family_members, :death_date, :date
  end
end
