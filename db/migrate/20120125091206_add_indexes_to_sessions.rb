class AddIndexesToSessions < ActiveRecord::Migration
  def self.up
    add_index :sessions, :id
    add_index :sessions, :user_id
  end

  def self.down
  end
end
