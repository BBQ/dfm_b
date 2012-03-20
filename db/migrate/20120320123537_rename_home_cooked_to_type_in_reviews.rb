class RenameHomeCookedToTypeInReviews < ActiveRecord::Migration
  def self.up
    rename_column :reviews, :home_cooked, :type
    change_column :reviews, :type, :string
  end

  def self.down
    rename_column :reviews, :type, :home_cooked
    change_column :reviews, :home_cooked, :boolean
  end
end
