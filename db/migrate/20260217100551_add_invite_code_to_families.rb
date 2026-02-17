class AddInviteCodeToFamilies < ActiveRecord::Migration[8.1]
  def change
    add_column :families, :invite_code, :string
    add_index :families, :invite_code, unique: true
  end
end
