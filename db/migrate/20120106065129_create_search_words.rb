class CreateSearchWords < ActiveRecord::Migration
  def self.up
    create_table :search_words, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name
      t.column :count, INT_UNSIGNED

      t.timestamps
    end
  end

  def self.down
    drop_table :search_words
  end
end
