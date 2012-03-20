class DeliveryTag < ActiveRecord::Base
  belongs_to :delivery
  belongs_to :tag
  
  validates :delivery_id, :uniqueness => {:scope => :tag_id}
end
