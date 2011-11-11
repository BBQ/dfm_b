#coding utf-8
require "unicode";
class String
    def downcase
     Unicode::downcase(self)
    end
    def downcase!
     self.replace downcase
    end
    def upcase
     Unicode::upcase(self)
    end
    def upcase!
     self.replace upcase
    end
    def capitalize
     Unicode::capitalize(self)
    end
    def capitalize!
     self.replace capitalize
    end
    def capitalize_first_letter
       self[0].chr.capitalize + self[1, size] unless self[0].blank?
    end
    def capitalize_first_letter!
      if self[0].blank? && self[0] != (c = self[0,1].upcase[0])
       self[0] = c
       self
      end
    end
end