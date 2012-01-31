class RecreateTagsTable < ActiveRecord::Migration
  def self.up
    create_table :tags, :id => false, :force => true do |t|
      t.column :id, ID_COLUMN
      t.string :name_a
      t.string :name_b
      t.string :name_c
      t.string :name_d
      t.string :name_e
      t.string :name_f

      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end
