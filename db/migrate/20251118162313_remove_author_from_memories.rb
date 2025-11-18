class RemoveAuthorFromMemories < ActiveRecord::Migration[8.1]
  def change
    remove_column :memories, :author, :string
  end
end
