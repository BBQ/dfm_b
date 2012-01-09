class AddCreatedByUserToDishes < ActiveRecord::Migration
  def self.up
    add_column :dishes, :created_by_user, :tinyint, :default => 0
  end

  def self.down
    remove_column :dishes, :created_by_user
  end
end
