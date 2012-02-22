class AddCityToNetwork < ActiveRecord::Migration
  def self.up
    add_column :networks, :city, :string
  end

  def self.down
    remove_column :networks, :city
  end
end
