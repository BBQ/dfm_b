class Special < ActiveRecord::Base
  
  def get_iiko
    system "rake special:get_iiko &"
  end
  
end
