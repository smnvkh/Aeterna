class RemoveUserIdFromComments < ActiveRecord::Migration[8.1]
  def change
      remove_reference :comments, :user, foreign_key: true
  end
end
