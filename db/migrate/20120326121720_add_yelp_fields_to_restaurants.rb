class AddYelpFieldsToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :ylp_rating, :float
    add_column :restaurants, :ylp_r_count, :integer
    add_column :restaurants, :attire, :string
    add_column :restaurants, :transit, :string
    add_column :restaurants, :caters, :string
    add_column :restaurants, :ambience, :string
    add_column :restaurants, :good_for_groups, :string
    add_column :restaurants, :good_for_meal, :string
    rename_column :restaurants, :children, :good_for_kids
    
    change_column :restaurants, :terrace, :string
    change_column :restaurants, :cc, :string
    change_column :restaurants, :chillum, :string
  end

  def self.down
    remove_column :restaurants, :ylp_r_count
    remove_column :restaurants, :ylp_rating
    remove_column :restaurants, :attire
    remove_column :restaurants, :transit
    remove_column :restaurants, :caters
    remove_column :restaurants, :ambience
    remove_column :restaurants, :transit
    remove_column :restaurants, :good_for_groups
    remove_column :restaurants, :good_for_meal
    rename_column :restaurants, :good_for_kids, :children
  end
end
