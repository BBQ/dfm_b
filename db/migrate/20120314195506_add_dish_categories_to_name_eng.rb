class AddDishCategoriesToNameEng < ActiveRecord::Migration
  def self.up
    add_column :dish_categories, :name_eng, :string
  end

  def self.down
    remove_column :dish_categories, :name_eng
  end
end
