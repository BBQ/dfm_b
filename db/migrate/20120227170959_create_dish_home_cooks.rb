class CreateDishHomeCooks < ActiveRecord::Migration
  def self.up
    create_table :dish_home_cooks, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name
      t.string :photo
      t.column :rating, INT_UNSIGNED
      t.column :votes, INT_UNSIGNED
      t.text :description
      :dish_type_id
      :dish_subtype_id
      :dish_extratype_id
      :created_by_user
      :count_comments
      :count_likes
      :top_user_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dish_home_cooks
  end
end
