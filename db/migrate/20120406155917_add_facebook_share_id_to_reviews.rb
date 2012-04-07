class AddFacebookShareIdToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :facebook_share_id, :string
  end

  def self.down
    remove_column :reviews, :facebook_share_id
  end
end
