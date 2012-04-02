class AddOauthTokenAndOauthTokenSecretToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :oauth_token_secret, :string
    add_column :users, :oauth_token, :string
  end

  def self.down
    remove_column :users, :oauth_token
    remove_column :users, :oauth_token_secret
  end
end
