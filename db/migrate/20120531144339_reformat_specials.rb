class ReformatSpecials < ActiveRecord::Migration
  def self.up
    rename_column :specials, :valid_until, :date_end

    add_column :specials, :date_start, :datetime    
    add_column :specials, :partner, :string
    add_column :specials, :out_id, :string
    add_column :specials, :photo, :string
    
  end

  def self.down
  end
end
