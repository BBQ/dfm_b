class AddRatingAndVotesToNetwork < ActiveRecord::Migration
  def self.up
    add_column :networks, :rating, INT_UNSIGNED
    add_column :networks, :votes, INT_UNSIGNED
    add_column :networks, :photo, :string
  end

  def self.down
    remove_column :networks, :photo
    remove_column :networks, :votes
    remove_column :networks, :rating
  end
end
