class AutocompleteSearchesController < ApplicationController

  def index
      data = []
      restaurants = Network.limit(10).where("LOWER(name) REGEXP '[[:<:]]#{params[:term].downcase}'").order('rating/votes DESC')   
      restaurants.each do |p|
        data << {:label => p.name, :value => p.name }
      end
      dishes = Dish.limit(10).where("LOWER(name) REGEXP '[[:<:]]#{params[:term].downcase}'").order('rating/votes DESC')  
      dishes.each do |p|
        data << {:label => p.name, :value => p.name }
      end
      return render :json => data.to_json
  end

end
