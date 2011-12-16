class AddTypeIdToDishSubtypes < ActiveRecord::Migration
  def self.up
    add_column :dish_subtypes, :dish_type_id, LINKED_ID_COLUMN
  end

  def self.down
    remove_column :dish_subtypes, :dish_type_id
  end
end
