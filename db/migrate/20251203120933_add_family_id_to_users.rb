class AddFamilyIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :family, null: false, foreign_key: true
  end
end
