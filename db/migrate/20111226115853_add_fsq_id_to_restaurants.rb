class AddFsqIdToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :fsq_id, :string
  end

  def self.down
    remove_column :restaurants, :fsq_id
  end
end
