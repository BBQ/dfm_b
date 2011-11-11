class AddPhotoNameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :photo, :string
    add_column :users, :name, :string
    add_column :users, :facebook_id, :bigint
  end

  def self.down
    remove_column :users, :name
    remove_column :users, :photo
    remove_column :users, :facebook_id
  end
end
