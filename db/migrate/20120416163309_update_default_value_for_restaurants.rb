class UpdateDefaultValueForRestaurants < ActiveRecord::Migration
  def self.up
    change_column_default(restaurants, breakfast, 0)
    change_column_default(restaurants, businesslunch, 0)
    change_column_default(restaurants, wifi, 0)
    change_column_default(restaurants, good_for_kids, 0)
    change_column_default(restaurants, delivery, 0)
    
    change_column_default(restaurants, banquet, 0)
    change_column :restaurants, :banquet, :boolean
    change_column_default(restaurants, reservation, 0)
    change_column :restaurants, :banquet, :boolean
    change_column_default(restaurants, takeaway, 0)
    change_column :restaurants, :takeaway, :boolean
    
    remove_column :restaurants, :good_for
    
    
    change_column_default(restaurants, breakfast, 0)
    change_column_default(restaurants, breakfast, 0)
    change_column_default(restaurants, breakfast, 0)
    change_column_default(restaurants, breakfast, 0)
    change_column_default(restaurants, breakfast, 0)
    change_column_default(restaurants, breakfast, 0)
  end

  def self.down
  end
end
