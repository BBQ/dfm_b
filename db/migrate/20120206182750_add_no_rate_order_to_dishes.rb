class AddNoRateOrderToDishes < ActiveRecord::Migration
  def self.up
   add_column :dishes, :no_rate_order, INT_UNSIGNED
  end

  def self.down
    remove_column :dishes, :no_rate_order
  end
end
