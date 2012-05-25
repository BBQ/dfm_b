class CreateWorkHours < ActiveRecord::Migration
  def self.up
    create_table :work_hours, :id => false do |t|
      t.column :id, ID_COLUMN
      t.column :restaurant_id, LINKED_ID_COLUMN
      t.column :sun, :string
      t.column :mon, :string
      t.column :tue, :string
      t.column :wed, :string
      t.column :thu, :string
      t.column :fri, :string
      t.column :sat, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :work_hours
  end
end
