class AddLatAndLonToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :lat, :double
    add_column :reviews, :lng, :double
  end

  def self.down
    remove_column :reviews, :lng
    remove_column :reviews, :lat
  end
end
