class AddImageToMemory < ActiveRecord::Migration[8.1]
  def change
    add_column :memories, :image, :string
  end
end
