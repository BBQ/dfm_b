# encoding: utf-8
class Tag < ActiveRecord::Base
  
  has_many :dish_tags
  has_many :dishes, :through => :dish_tags
  
  def self.get_all(timestamp = nil)
  
    ids = {
      1 => ['салат','salad','салатик'],
      2 => ['soup','суп','супы','супчик','супчики','супец'],
      3 => ['pasta','паста','пасты','спагетти'],
      4 => ['pizza','пицца','пиццы'],
      5 => ['burger','бургер'],
      6 => ['noodles','лапша'],
      7 => ['risotto','ризотто'],
      8 => ['rice','рис'],
      9 => ['steak','стейк','стэйк'],
      10 => ['sushi & rolls','суши и роллы','суши','sushi','ролл','сашими'],
      11 => ['desserts','десерт','торт','пирожные','пирожное','выпечка','мороженое','пирог','сладости','сорбет'],
      12 => ['drinks','напитки','напиток'],
      13 => ['meat','мясо','мясное'],
      14 => ['fish','рыба','морепродукты','креветки','мидии','форель','треска','карп','моллюски','устрицы','сибас','лосось','судак'],
      15 => ['vegetables','овощи','овощь']
    }
  
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
