class AddNetworkIdToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :network_id, INT_UNSIGNED
  end

  def self.down
    remove_column :reviews, :network_id
  end
end
