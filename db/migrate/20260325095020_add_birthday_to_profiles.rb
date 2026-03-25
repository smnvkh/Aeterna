class AddBirthdayToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :birthday, :date
  end
end
