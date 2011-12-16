class AddNameEngToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :name_eng, :string
    add_index :restaurants, :name_eng
  end

  def self.down
    remove_column :restaurants, :name_eng
  end
end
