class CreateCollectionMemories < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_memories do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :memory, null: false, foreign_key: true

      t.timestamps
    end

    add_index :collection_memories, [ :collection_id, :memory_id ], unique: true
  end
end
