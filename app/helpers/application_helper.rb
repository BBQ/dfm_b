module ApplicationHelper
  
  def fb_opengraph_meta_tag(action=nil)
    raw %Q{<meta property="fb:app_id" content="#{Rails.application.config.sorcery.facebook.key}" />
    <meta property="og:type" content="dish_fm:comment" />
    <meta property="og:title" content="Stuffed Cookies" />
    <meta property="og:image" content="http://fbwerks.com:8000/zhen/cookie.jpg" />
    <meta property="og:description" content="The Turducken of Cookies" />
    <meta property="og:url" content="http://fbwerks.com:8000/zhen/cookie.html">
    }
  end
  
end
