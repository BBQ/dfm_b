class AddOrderToTypes < ActiveRecord::Migration
  def self.up
    add_column :dish_types, :order, INT_UNSIGNED
  end

  def self.down
    remove_column :dish_types, :order
  end
end
