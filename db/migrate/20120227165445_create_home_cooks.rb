class CreateHomeCooks < ActiveRecord::Migration
  def self.up
    create_table :home_cooks, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name
      t.string :photo
      t.column :rating, INT_UNSIGNED
      t.column :votes, INT_UNSIGNED
      t.text :description
      t.column :dish_type_id, LINKED_ID_COLUMN
      t.column :dish_subtype_id, LINKED_ID_COLUMN
      t.column :dish_extratype_id, LINKED_ID_COLUMN
      t.column :created_by_user, LINKED_ID_COLUMN
      t.column :count_comments, INT_UNSIGNED
      t.column :count_likes, INT_UNSIGNED
      t.column :top_user_id, INT_UNSIGNED
      
      t.timestamps
    end
  end

  def self.down
    drop_table :home_cooks
  end
end
