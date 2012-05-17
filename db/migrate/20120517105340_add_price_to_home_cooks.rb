class AddPriceToHomeCooks < ActiveRecord::Migration
  def self.up
    add_column :home_cooks, :price, :decimal
  end

  def self.down
    remove_column :home_cooks, :price
  end
end
