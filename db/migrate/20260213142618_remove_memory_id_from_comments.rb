class RemoveMemoryIdFromComments < ActiveRecord::Migration[8.1]
  def change
    remove_column :comments, :memory_id, :integer
  end
end
