class AddCoverToMemory < ActiveRecord::Migration[8.1]
  def change
    add_column :memories, :cover, :string
  end
end
