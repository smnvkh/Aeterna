class AddDecorIconToCollections < ActiveRecord::Migration[8.1]
  def change
    add_column :collections, :decor_icon, :string
  end
end
