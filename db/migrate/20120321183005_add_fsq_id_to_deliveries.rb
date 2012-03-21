class AddFsqIdToDeliveries < ActiveRecord::Migration
  def self.up
    add_column :deliveries, :fsq_id, :string
  end

  def self.down
    remove_column :deliveries, :fsq_id
  end
end
