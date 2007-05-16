ActiveRecord::Schema.define :version => 0 do
  create_table :tags, :force => true do |t|
    t.column :name, :string
    t.column :taggings_count, :integer, :default => 0, :null => false
  end
  add_index :tags, :name 
  add_index :tags, :taggings_count

  create_table :taggings, :force => true do |t|
    t.column :tag_id, :integer
    t.column :taggable_id, :integer
    t.column :taggable_type, :string
  end
  add_index :taggings, [:tag_id, :taggable_type] 
  add_index :taggings, [:taggable_id, :taggable_type, :tag_id]
  
  create_table :things, :force => true do |t|
    t.column :name, :string
  end
end