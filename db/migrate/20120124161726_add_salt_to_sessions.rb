class AddSaltToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :salt, :string
  end

  def self.down
    remove_column :sessions, :salt
  end
end
