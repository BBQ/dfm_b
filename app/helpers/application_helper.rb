module ApplicationHelper
  
  def fb_opengraph_meta_tag
    if @fb_obj
      
      domain = "http://dish.fm"
      app_id = Rails.application.config.sorcery.facebook.key
      type = @fb_obj.class.name.downcase
      url = "#{domain}#{eval "#{type}_path(#{@fb_obj.id})" }"
      
      case type
        when 'dish'
          title = "#{@fb_obj.name}"
          description = "Rating: #{@fb_obj.rating.round(1)} (#{@fb_obj.votes} vote(s)). #{@fb_obj.description}"
          image = "#{domain}#{@fb_obj.image_hd}"
        when 'restaurant'
          title = "#{@fb_obj.name}"
          description = "Rating: #{@fb_obj.rating.round(1)} (#{@fb_obj.votes} vote(s)). Popularity: #{@fb_obj.fsq_checkins_count} checkins. #{@fb_obj.description}"
          image = "#{domain}#{@fb_obj.thumb}"
        when 'review' 
          title = "#{@fb_obj.dish.name} review by #{@fb_obj.user.name}"
          description = "#{@fb_obj.dish.name} in #{@fb_obj.restaurant ? @fb_obj.restaurant.name : 'Home Cooked'}"
          image = "#{domain}#{@fb_obj.photo.iphone.url}"
        when 'user' 
          title = "#{@fb_obj.name}"
          description = "#{@fb_obj.name} is using Dish.fm to find and share the best dishes around."
          image = "#{@fb_obj.user_photo}"
      end
      
      raw %Q{<meta property="fb:app_id" content="#{app_id}" />
      <meta property="og:type" content="dish_fm:#{type}" />
      <meta property="og:title" content="#{title}" />
      <meta property="og:image" content="#{image}" />
      <meta property="og:description" content="#{description}" />
      <meta property="og:url" content="#{url}">
      }
    end
  end
  
end
