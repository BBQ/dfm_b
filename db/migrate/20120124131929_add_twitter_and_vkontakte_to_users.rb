class AddTwitterAndVkontakteToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_id, :string
    add_column :users, :vkontakte_id, :string
  end

  def self.down
    remove_column :users, :vkontakte_id
    remove_column :users, :twitter_id
  end
end
