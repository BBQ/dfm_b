class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :photo
      t.column :rating, INT_UNSIGNED
      t.text :text
      t.column :dish_id, LINKED_ID_COLUMN
      t.column :user_id, LINKED_ID_COLUMN
      t.column :restaurant_id, LINKED_ID_COLUMN
      t.column :count_likes, INT_UNSIGNED
      t.column :count_comments, INT_UNSIGNED
      t.boolean :web, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
