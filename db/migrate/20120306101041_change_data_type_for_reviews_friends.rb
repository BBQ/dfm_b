class ChangeDataTypeForReviewsFriends < ActiveRecord::Migration
  def self.up
    change_table :reviews do |t|
      t.change :friends, :text
    end
  end

  def self.down
    change_table :reviews do |t|
      t.change :friends, :string
    end
  end
end
