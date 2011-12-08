class ChangeDataTypeForRating < ActiveRecord::Migration
  def self.up
    change_table :dishes do |t|
          t.change :rating, :float
    end
    change_table :restaurants do |t|
          t.change :rating, :float
    end
    change_table :networks do |t|
          t.change :rating, :float
    end
    change_table :reviews do |t|
          t.change :rating, :float
    end
  end

  def self.down
    change_table :dishes do |t|
          t.change :rating, :integer
    end
    change_table :restaurants do |t|
          t.change :rating, :integer
    end
    change_table :networks do |t|
          t.change :rating, :integer
    end
    change_table :reviews do |t|
          t.change :rating, :integer
    end
  end
end
