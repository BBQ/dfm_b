class AddPhotoToDishTypes < ActiveRecord::Migration
  def self.up
    add_column :dish_types, :photo, :string
  end

  def self.down
    remove_column :dish_types, :photo
  end
end
