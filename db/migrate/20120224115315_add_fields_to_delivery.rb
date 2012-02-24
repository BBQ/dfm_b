class AddFieldsToDelivery < ActiveRecord::Migration
  def self.up
    add_column :deliveries, :name_eng, :string
    add_column :deliveries, :top_user_id, INT_UNSIGNED
    
    add_column :dish_deliveries, :top_user_id, INT_UNSIGNED
    add_column :dish_deliveries, :dish_extratype_id, INT_UNSIGNED
    add_column :dish_deliveries, :created_by_user, INT_UNSIGNED
    add_column :dish_deliveries, :count_comments, INT_UNSIGNED
    add_column :dish_deliveries, :count_likes, INT_UNSIGNED
    add_column :dish_deliveries, :no_rate_order, INT_UNSIGNED
    
  end

  def self.down
    remove_column :deliveries, :name_eng
    remove_column :deliveries, :top_user_id
    
    remove_column :dish_deliveries, :top_user_id
    remove_column :dish_deliveries, :dish_extratype_id
    remove_column :dish_deliveries, :created_by_user
    remove_column :dish_deliveries, :count_comments
    remove_column :dish_deliveries, :count_likes
    remove_column :dish_deliveries, :no_rate_order
  end
end
