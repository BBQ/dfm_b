class DishesChangeTypeOfPrice < ActiveRecord::Migration
  def self.up
    change_column :dishes, :price, :decimal
  end

  def self.down
    change_column :dishes, :price, :integer
  end
end
