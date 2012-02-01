class AddFsqCheckinsCountToNetworks < ActiveRecord::Migration
  def self.up
    add_column :networks, :fsq_checkins_count, INT_UNSIGNED
  end

  def self.down
    remove_column :networks, :fsq_checkins_count
  end
end
