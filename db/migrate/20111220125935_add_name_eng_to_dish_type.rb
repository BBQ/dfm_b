class AddNameEngToDishType < ActiveRecord::Migration
  def self.up
    add_column :dish_types, :name_eng, :string
  end

  def self.down
    remove_column :dish_types, :name_eng
  end
end
