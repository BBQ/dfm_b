class CreateNetworks < ActiveRecord::Migration
  def self.up
    create_table :networks, :id => false do |t|
      t.column :id, ID_COLUMN
      t.string :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :networks
  end
end
