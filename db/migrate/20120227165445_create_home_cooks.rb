class CreateHomeCooks < ActiveRecord::Migration
  def self.up
    create_table :home_cooks, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :photo
      t.column :rating, INT_UNSIGNED
      t.text :text
      t.column :dish_id, LINKED_ID_COLUMN
      t.column :user_id, LINKED_ID_COLUMN
      t.column :count_likes, INT_UNSIGNED
      t.column :count_comments, INT_UNSIGNED

      t.timestamps
    end
  end

  def self.down
    drop_table :home_cooks
  end
end
