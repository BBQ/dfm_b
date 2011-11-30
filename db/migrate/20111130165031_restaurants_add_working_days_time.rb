class RestaurantsAddWorkingDaysTime < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :sun, :string
    add_column :restaurants, :mon, :string
    add_column :restaurants, :tue, :string
    add_column :restaurants, :wed, :string
    add_column :restaurants, :thu, :string
    add_column :restaurants, :fri, :string
    add_column :restaurants, :sat, :string
  end

  def self.down
    remove_column :restaurants, :sun
    remove_column :restaurants, :mon
    remove_column :restaurants, :tue
    remove_column :restaurants, :wed
    remove_column :restaurants, :thu
    remove_column :restaurants, :fri
    remove_column :restaurants, :sat
  end
end
