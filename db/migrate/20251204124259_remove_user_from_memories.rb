class RemoveUserFromMemories < ActiveRecord::Migration[8.1]
  def change
    remove_reference :memories, :user, null: false, foreign_key: true
  end
end
