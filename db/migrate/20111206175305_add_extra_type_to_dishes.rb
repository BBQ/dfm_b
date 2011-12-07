class AddExtraTypeToDishes < ActiveRecord::Migration
  def self.up
    add_column :dishes, :dish_extratype_id, INT_UNSIGNED
  end

  def self.down
    remove_column :dishes, :dish_extratype_id
  end
end
