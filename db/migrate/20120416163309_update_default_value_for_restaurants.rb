class UpdateDefaultValueForRestaurants < ActiveRecord::Migration
  def self.up
    change_column_default('restaurants', 'breakfast', 0)
    change_column_default('restaurants', 'businesslunch', 0)
    change_column_default('restaurants', 'wifi', 0)
    change_column_default('restaurants', 'good_for_kids', 0)
    change_column_default('restaurants', 'delivery', 0)
    
    change_column_default('restaurants', 'banquet', 0)
    change_column :restaurants, :banquet, :boolean
    change_column_default('restaurants', 'reservation', 0)
    change_column :restaurants, :banquet, :boolean
    change_column_default('restaurants', 'takeaway', 0)
    change_column :restaurants, :takeaway, :boolean    
    
    change_column_default('restaurants', 'service', 0)
    change_column :restaurants, :service, :boolean
    change_column_default('restaurants', 'tv', 0)
    change_column :restaurants, :tv, :boolean
    change_column_default('restaurants', 'good_for_groups', 0)
    change_column :restaurants, :good_for_groups, :boolean
    
    change_column_default('restaurants', 'alcohol', 0)
    change_column_default('restaurants', 'noise', 0)
    change_column_default('restaurants', 'disabled', 0)
    change_column_default('restaurants', 'music', 0)
    change_column_default('restaurants', 'parking', 0)
    
    change_column_default('restaurants', 'attire', 0)
    change_column_default('restaurants', 'transit', 0)
    change_column_default('restaurants', 'caters', 0)
    change_column_default('restaurants', 'ambience', 0)
    change_column_default('restaurants', 'good_for_meal', 0)
    
    remove_column :'restaurants', :good_for
  end

  def self.down
  end
end
