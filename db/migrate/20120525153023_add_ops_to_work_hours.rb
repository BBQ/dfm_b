class AddOpsToWorkHours < ActiveRecord::Migration
  def self.up
    add_column :work_hours, :time_zone_offset, :string
    
    add_index :work_hours, :sun
    add_index :work_hours, :mon
    add_index :work_hours, :tue
    add_index :work_hours, :wed
    add_index :work_hours, :thu
    add_index :work_hours, :fri
    add_index :work_hours, :sat
    
  end

  def self.down
  end
end
