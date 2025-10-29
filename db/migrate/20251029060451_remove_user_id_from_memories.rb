class RemoveUserIdFromMemories < ActiveRecord::Migration[8.1]
    def change
      remove_reference :memories, :user, foreign_key: true
    end
end
