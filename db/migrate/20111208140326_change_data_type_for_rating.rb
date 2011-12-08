class ChangeDataTypeForRating < ActiveRecord::Migration
  
  # UPDATE restaurants SET rating = rating / votes;
  # UPDATE dishes SET rating = rating / votes;
  # UPDATE networks SET rating = rating / votes;
  # 
  # UPDATE restaurants SET rating = 0 WHERE rating IS NULL;
  # UPDATE dishes SET rating = 0 WHERE rating IS NULL;
  # UPDATE networks SET rating = 0 WHERE rating IS NULL;
  # 
  # alter table restaurants change rating rating float(21,20);
  # alter table dishes change rating rating float(21,20);
  # alter table networks change rating rating float(21,20);
  # 
  # UPDATE reviews SET rating = rating / 2;
  # UPDATE restaurants SET rating = rating / 2;
  # UPDATE dishes SET rating = rating / 2;
  # UPDATE networks SET rating = rating / 2;
  
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
