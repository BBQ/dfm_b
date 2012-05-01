module ApplicationHelper
  
  def fb_opengraph_meta_tag
    if @fb_obj
      raw %Q{<meta property="fb:app_id" content="#{Rails.application.config.sorcery.facebook.key}" />
      <meta property="og:type" content="dish_fm:#{@fb_obj}" />
      <meta property="og:title" content="Denish" />
      <meta property="og:image" content="http://test.dish.fm/uploads/review/photo/130/iphone_retina_e2dbf593-952f-4499-b1fd-070e8d04a5bb.jpg" />
      <meta property="og:description" content="Denish" />
      <meta property="og:url" content="http://test.dish.fm/reviews/130">
      }
    end
  end
  
end
