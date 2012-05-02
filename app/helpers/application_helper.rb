module ApplicationHelper
  
  def fb_opengraph_meta_tag
    if @fb_obj
      
      domain = "http://test.dish.fm"
      app_id = Rails.application.config.sorcery.facebook.key
      type = @fb_obj.class.name.downcase
      image = "#{domain}#{@fb_obj.photo.iphone.url}"
      url = "#{domain}#{eval "#{type}_path(#{@fb_obj.id})" }"
      
      case type
        when 'dish'
          title = "#{@fb_obj.name}"
          description = "#{@fb_obj.description}"
        when 'restaurant'
          title = "#{@fb_obj.name}"
          description = "#{@fb_obj.description}"
        when 'review' 
          title = "#{@fb_obj.dish.name}"
          description = "#{@fb_obj.dish.name} in #{@fb_obj.restaurant.name}"
      end
      
      raw %Q{<meta property="fb:app_id" content="#{app_id}" />
      <meta property="og:type" content="dish_fm:#{type}" />
      <meta property="og:title" content="title" />
      <meta property="og:image" content="#{image}" />
      <meta property="og:description" content="#{description}" />
      <meta property="og:url" content="#{url}">
      }
    end
  end
  
end
