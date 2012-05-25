class WorkHour < ActiveRecord::Base
  validates :restaurant_id, :uniqueness => {:scope => [:mon, :tue, :wed, :thu, :fri, :sat, :sun]}
  belongs_to :restaurant
end