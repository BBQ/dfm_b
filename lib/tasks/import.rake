# encoding: utf-8
namespace :import do
  task :location_tips => :environment do |t, args|
    
    require 'csv'
  
    directory = File.dirname(__FILE__).sub('/lib/tasks', '') + '/import/'
    file = directory + 'Catogories.xlsx'
    parser = Excelx.new(file, false, :ignore)  
        
    dish_sheet = parser.sheets[6]
    1.upto(parser.last_row(dish_sheet)) do |line|
      LocationTip.create(:name => parser.cell(line,'A', dish_sheet))
      p parser.cell(line,'A', dish_sheet)
    end
  
  end
  
end