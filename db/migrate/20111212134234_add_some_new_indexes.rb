class AddSomeNewIndexes < ActiveRecord::Migration
  def self.up
    add_index :restaurants, :network_id
    add_index :restaurants, :lat
    add_index :restaurants, :lon
    
    add_index :reviews, :id
    add_index :reviews, :dish_id
    add_index :reviews, :user_id 
    add_index :reviews, :count_likes    
    
    add_index :dishes, :rating
    add_index :dishes, :votes
    add_index :dishes, :photo
    
    add_index :networks, :rating
    add_index :networks, :votes
  end

  def self.down
  end
end
