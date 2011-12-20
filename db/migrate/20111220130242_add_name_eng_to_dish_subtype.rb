class AddNameEngToDishSubtype < ActiveRecord::Migration
  def self.up
    add_column :dish_subtypes, :name_eng, :string
  end

  def self.down
    remove_column :dish_subtypes, :name_eng
  end
end
