class AddHomeCookedToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :home_cooked, :boolean
  end

  def self.down
    remove_column :reviews, :home_cooked
  end
end
