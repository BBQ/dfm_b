class AddInfoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gender, :string
    add_column :users, :current_city, :string
  end

  def self.down
    remove_column :users, :current_city
    remove_column :users, :gender
  end
end
