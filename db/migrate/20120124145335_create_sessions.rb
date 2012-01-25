class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :user_id, INT_UNSIGNED
      t.string :session_token

      t.timestamps
    end
  end

  def self.down
    drop_table :sessions
  end
end
