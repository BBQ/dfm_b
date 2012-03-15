# encoding: utf-8
class Tag < ActiveRecord::Base
  
  has_many :dish_tags
  has_many :dishes, :through => :dish_tags
  
  has_many :dish_delivery_tags
  has_many :dish_deliveries, :through => :dish_delivery_tags
  
  has_many :home_cook_tags
  has_many :home_cooks, :through => :home_cook_tags
  
  def self.get_all(timestamp = nil)
    all_tags = [] 
    tags = timestamp ? Tag.where('updated_at >= ?', timestamp) : Tag.all
    
    tags.each do |t|
      all_tags.push({:id => t.id, :name => t.name_a}) unless t.name_a.blank?
      all_tags.push({:id => t.id, :name => t.name_b}) unless t.name_b.blank?
      all_tags.push({:id => t.id, :name => t.name_c}) unless t.name_c.blank?
      all_tags.push({:id => t.id, :name => t.name_d}) unless t.name_d.blank?
      all_tags.push({:id => t.id, :name => t.name_e}) unless t.name_e.blank?
      all_tags.push({:id => t.id, :name => t.name_f}) unless t.name_f.blank?
    end
    all_tags
  end
  
  def self.get_all_old(timestamp = nil)
    
    all_tags = [] 
    tags = timestamp ? Tag.select([:id, :name]).where('updated_at >= ?', timestamp) : Tag.select([:id, :name])
    tags.each do |t|
      added = 0
      ids.each do |k,v|
        if t.id == k
          v.each {|name| all_tags.push({:id => k, :name => name})}
          ids.delete(k)
          added = 1          
        end
      end
      all_tags.push({:id => t.id, :name => t.name}) if added != 1
    end
    all_tags
  end
  
end
