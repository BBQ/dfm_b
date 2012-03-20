class RenameTypeToRtypeInReviews < ActiveRecord::Migration
  def self.up
    rename_column :reviews, :type, :rtype
  end

  def self.down
    rename_column :reviews, :rtype, :type
  end
end
