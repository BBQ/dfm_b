class AddBillToDelivery < ActiveRecord::Migration
  def self.up
    add_column :deliveries, :bill, INT_UNSIGNED
  end

  def self.down
    remove_column :deliveries, :bill
  end
end
