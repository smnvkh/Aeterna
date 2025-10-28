class AddAuthorToMemory < ActiveRecord::Migration[8.1]
  def change
    add_column :memories, :author, :string
  end
end
