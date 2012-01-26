class AddDishSingleRatingToDishes < ActiveRecord::Migration
  def self.up
    add_column :dishes, :single_rating, :integer, :default => 0
  end

  def self.down
    remove_column :dishes, :single_rating
  end
end
