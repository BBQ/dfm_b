class CreateParserStats < ActiveRecord::Migration
  def self.up
    create_table :parser_stats, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :find_loc, :string
      t.column :cflt, :string
      t.column :url, :string
      t.timestamps
    end
      add_index :parser_stats, :find_loc
      add_index :parser_stats, :cflt
  end

  def self.down
    drop_table :parser_stats
  end
end
