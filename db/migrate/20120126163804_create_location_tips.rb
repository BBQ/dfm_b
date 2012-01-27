class CreateLocationTips < ActiveRecord::Migration
  def self.up
    create_table :location_tips, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :location_tips
  end
end
