class AddNoRateOrderIndex < ActiveRecord::Migration
  def self.up
    add_index :dishes, :no_rate_order
  end

  def self.down
  end
end
