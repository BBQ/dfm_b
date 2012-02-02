class AddFsq_networkCheckinsCountToDishes < ActiveRecord::Migration
  def self.up
    add_column :dishes, :fsq_checkins_count, INT_UNSIGNED
  end

  def self.down
    remove_column :dishes, :fsq_checkins_count
  end
end
