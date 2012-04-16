class AddFbTokenValidToToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_valid_to, :datetime
  end

  def self.down
    remove_column :users, :fb_valid_to
  end
end
