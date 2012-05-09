class AddOrderToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :order, INT_UNSIGNED
    add_index :tags, :order
  end

  def self.down
    remove_column :tags, :order
  end
end
