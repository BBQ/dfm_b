class Special < ActiveRecord::Base
  
  validates :out_id, :uniqueness => {:scope => [:partner, :restaurant_id]}
  
  def self.get_iiko
    system "rake get_iiko_specials &"
  end
  
end
