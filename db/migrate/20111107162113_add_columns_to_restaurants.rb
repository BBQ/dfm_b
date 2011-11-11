class AddColumnsToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :children, :string
    add_column :restaurants, :banquet, :string
    add_column :restaurants, :reservation, :string
    add_column :restaurants, :delivery, :string
    add_column :restaurants, :takeaway, :string
    add_column :restaurants, :service, :string
    add_column :restaurants, :good_for, :string
    add_column :restaurants, :alcohol, :string
    add_column :restaurants, :noise, :string
    add_column :restaurants, :tv, :string
    add_column :restaurants, :disabled, :string
    add_column :restaurants, :music, :string
    add_column :restaurants, :menu_url, :string
    add_column :restaurants, :parking, :string
    add_column :restaurants, :description, :text
    change_column :restaurants, :wifi, :string
  end

  def self.down
    remove_column :restaurants, :children
    remove_column :restaurants, :banquet
    remove_column :restaurants, :reservation
    remove_column :restaurants, :delivery
    remove_column :restaurants, :takeaway
    remove_column :restaurants, :service
    remove_column :restaurants, :good_for
    remove_column :restaurants, :alcohol
    remove_column :restaurants, :noise
    remove_column :restaurants, :tv
    remove_column :restaurants, :disabled
    remove_column :restaurants, :music
    remove_column :restaurants, :menu_url
    remove_column :restaurants, :parking
    remove_column :restaurants, :description
    change_column :restaurants, :wifi, :boolean
  end
end
