$(document).ready(function() {
	
	// Init
	float_filters()
	slider()
	floats()
	stars()
	infinit_scroll()
		
	//Cities list
	$('#location').click(function(){
		$('#cities').slideToggle('fast')
		return false
	});
	
	$('#cities li').click(function(){
		image = $('#location img').attr('src')
		$('#location').html($(this).text() + " <img src=\"" + image + "\" >")
		$('#cities').slideToggle('fast')
		return false
	});
	
	//Main menu
	var menu_set = '#ratings, #feed, #logged'
	$(menu_set).click(function(e){
		if(!$(this).hasClass('selected')) {
			$(menu_set).removeClass('selected')
			$(this).addClass('selected')
		}
		if (e.target === this || e.target.id == 'feed_img' || e.target.id == 'rate_img' || e.target.id == 'logged_img') {
			$('.sub li a').removeClass('active').removeClass('selected')
			$('li a', $(this).children('ul.sub')).first().addClass('active').addClass('selected')
			$.getScript($('li a', $(this).children('ul.sub')).first().attr('href'), function() {
				floats();
				load_map();
				stars();
				slider();
				float_filters();
			});
		}
		return false
	});	
	
	$(menu_set).mouseenter(function(){
			$(menu_set).removeClass('active')
			$(this).addClass('active')
	});
	
	$(menu_set).mouseleave(function(){
			$(this).removeClass('active')
			$('li.selected').addClass('active')
	});	
	
	$('.sub li a').click(function(){
		$('.sub li a').removeClass('active').removeClass('selected')
		$(this).addClass('active').addClass('selected')
			$.getScript(this.href, function() {
			floats();
			load_map();
			stars();
			slider();
			float_filters();
		});
		return false
	});
	
	$('.sub li a').mouseover(function(){
		$('.sub li a').removeClass('active')
		$(this).addClass('active')
	});
	
	$('.sub li a').mouseout(function(){
		$(this).removeClass('active')
		$('.sub li a.selected').addClass('active')
	});
	
	//Likes
	$('.photo').live({
		mouseenter: function(){
			$('.like_me').css('display', 'none');		
			$(this).children('.heart').children('.like_me').css('display', 'block').show("slide", { direction: "down" }, 220)
			},
			mouseleave: function(){
				$(this).children('.heart').children('.like_me').hide("slide", { direction: "down" }, 120)
			}
		});
	
	$('.like_me, .like').click(function(){
		obj = $(this)
		success = 0
		$.getScript(this.href, function(){
			if(success == 1){
				obj.toggleClass('active')
				if (obj.hasClass('like_me'))
					obj.parents('.feed').children('.review').children('.data').children('.like').toggleClass('active')
				else
					obj.parents('.feed').children('.photo').children('.heart').children('.like_me').toggleClass('active')
			}
		})
		return false
	})	
	
	//Search
	$('#search_find').blur(function(){
		if ($(this).val() == '')
		$(this).val('искать блюдо, ресторан, кухню')
	});
	
	$('#search_find').focus(function(){
		if ($(this).val() == 'искать блюдо, ресторан, кухню')
		$(this).val('')
	});	
		
	//More Filters
	$('.more', '#filters').live('click',function(){
		$('#more_filters').slideToggle('fast').css('display', 'block')
		$(this).children('img').toggle()
		return false
	})
	
	//More Tags
	$('.more', '#tags').live('click',function(){
		$('.cut').toggle()
		$(this).children('img').toggle()
		return false
	})	
	
	//Similar Places
	$('.place').click(function(){
		 window.open($(this).children('p').children('a').attr('href'));
	})
	
	//Restaurant info menu
	$('a.menu_button').live('click', function(){
			$('#menu_list li').removeClass('active')
			$(this).parent('li').addClass('active')
			$.getScript(this.href)
		 return false
	})
	
	//Animate add_review button
	$('#review_submit').hover(function(){
			$('#review_submit').toggleClass('review_submit_hover')
	})
	
	// Fb_connect
	$('#fb_connect').live('click', function(){
		$(this).remove()
		$('#fb_loader').show()
		$('#simple_popup .message').html('Авторизирую').css('margin-top','0').parent().css('width','285px')
		
	})
	
	// Hide popup on click out
	$("body").live('click', function(e){
		if (e.target.id != 'simple_popup' && e.target.id != 'fb_loader_img' && !$('#simple_popup').has(e.target).length){
			$("#simple_popup").remove();	
		}
		if (!$('#popup').has(e.target).length)
		{
			$("#popup_layer").hide();
			$('body').css('overflow-y', 'scroll').css('padding-right', '0')
		}
	});
	
	$("body").live('keyup', function(e) {
    if (e.keyCode == 27) {
			if ($("#popup_layer").length){
				$("#popup_layer").hide();
				$('body').css('overflow-y', 'scroll').css('padding-right', '0')
			}
			if ($("#popup_layer").length){
				$("#simple_popup").remove();
			}
    }
	});
	
	// Close simple popup
	$('.close').live('click', function(){
		$(this).parent().remove()
		return false
	})
	
	//Show info-popup
	$('.show').live('click', function(){
		$.getScript(this.href, function(){
			$('body').css('overflow', 'hidden').css('padding-right', '15px')
			load_map();
		});
		return false
	})

	//Close popup
	$('.close_popup').live('click', function(){
			$(this).parent().parent().hide()
			$('body').css('overflow-y', 'scroll').css('padding-right', '0')
		 return false
	})
	
	//Show add comment field
	$('.comment').live('click', function(){
		result = 0
		obj = $(this).parents('.feed').next('.comments').children('.comment_form')
		$.getScript('/sessions/check/user', function() {
			if (result == 1){
				obj.slideToggle(10, function() {$('#reviews').masonry('reload')})
			}
		});
		return false
	});
	
	//Remove textarea comment content
	$('.add_comment').live('blur', function(){
		if ($(this).val() == '')
		$(this).val('написать комментарий')
	});
	
	$('.add_comment').live('focus', function(){
		if ($(this).val() == 'написать комментарий')
		$(this).val('')
	});
	
	//Submit comment on Enter
	$('textarea.add_comment').live('keypress', function(e) {
    if (e.keyCode == 13) {
			var form = $(this).parent('form')
			$.get(form.attr("action"), form.serialize(), function(){$('#wrapper').masonry('reload')}, "script")
      return false;
    }
	});
		
})

//Floating filters
function float_filters(obj) {
	obj = obj ? $(obj) : $("#filters")
	if (obj.length){ 
	  var pos = obj.offset()
	  $(window).scroll(function () {
			styles = $(document).scrollTop() > pos.top ? {'position':'fixed', 'left':pos.left, 'top':0} : {'position':'relative', 'left':0}
			obj.css(styles)
	  });
	}
	// offset = $(document).scrollTop() > y ? $(document).scrollTop() - y +"px" : "0px"
	// scroll_obj.animate({'margin-top':offset},{duration:0,queue:false});
}

//Google maps
function load_map() {
  var myOptions = {
		mapTypeControl: false,
		streetViewControl: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  if ($("#map_canvas").length) {
		var map = new google.maps.Map($("#map_canvas")[0], myOptions);
		setMarkers(map, markers);
	}
	if ($("#map_canvas_popup").length) {
		var map = new google.maps.Map($("#map_canvas_popup")[0], myOptions);
	}
}

// Add markers to the map
function setMarkers(map, locations) {
  // Add markers to the map

  // Marker sizes are expressed as a Size of X,Y
  // where the origin of the image (0,0) is located
  // in the top left of the image.

  // Origins, anchor positions and coordinates of the marker
  // increase in the X direction to the right and in
  // the Y direction down.
  var image = new google.maps.MarkerImage('http://code.google.com/intl/ru-RU/apis/maps/documentation/javascript/examples/images/beachflag.png',
      // This marker is 20 pixels wide by 32 pixels tall.
      new google.maps.Size(20, 32),
      // The origin for this image is 0,0.
      new google.maps.Point(0,0),
      // The anchor for this image is the base of the flagpole at 0,32.
      new google.maps.Point(0, 32));
  var shadow = new google.maps.MarkerImage('http://code.google.com/intl/ru-RU/apis/maps/documentation/javascript/examples/images/beachflag_shadow.png',
      // The shadow image is larger in the horizontal dimension
      // while the position and offset are the same as for the main image.
      new google.maps.Size(37, 32),
      new google.maps.Point(0,0),
      new google.maps.Point(0, 32));
      // Shapes define the clickable region of the icon.
      // The type defines an HTML <area> element 'poly' which
      // traces out a polygon as a series of X,Y points. The final
      // coordinate closes the poly by connecting to the first
      // coordinate.
  var shape = {
      coord: [1, 1, 1, 20, 18, 20, 18, 1],
      type: 'poly'
  };
	var bounds = new google.maps.LatLngBounds();
  for (var i = 0; i < locations.length; i++) {
    var beach = locations[i];
    var myLatLng = new google.maps.LatLng(beach[1], beach[2]);
    var marker = new google.maps.Marker({
        position: myLatLng,
        map: map,
        shadow: shadow,
        icon: image,
        shape: shape,
        title: beach[0],
        zIndex: beach[3]
    });
	bounds.extend(myLatLng);
  map.fitBounds(bounds);
  }
}

//Get bottom of page
function nearBottomOfPage() {
  return $(window).scrollTop() > $(document).height() - $(window).height() - 200;
}

// Infinit scroll
function infinit_scroll() {
	loading = false;
	page = 1;
  $(window).scroll(function(){
		if ($('#dishes').length) {
   	 if (loading)
	      return;
			if(nearBottomOfPage()) {
	      loading=true;
	      page++;
				$.getScript('/dishes?page=' + page, function() {
					$dishes = $('#dishes')
					$dishes.imagesLoaded(function(){
					  $dishes.masonry('reload')
					});
					$(".stars").rating({showCancel: null});
	        loading=false;
				});
			}
    }
	});
}

//Filters Slider
function slider() {
	$("#slider").slider({ 
		animate: true,
		min: 200,
		max: 2000,
		step: 50,
		value: 1100,
		slide: function(event, ui) {
			$("#amount").text(ui.value + ' руб.')}
		});
}

// Floats
function floats() {
	var $dishes = $('#dishes');
	$dishes.imagesLoaded(function(){
	  $dishes.masonry({
	    itemSelector : '.dish'
	  });
	});
	var $restaurants = $('#restaurants');
	$restaurants.imagesLoaded(function(){
	  $restaurants.masonry({
	    itemSelector : '.restaurant_obj'
	  });
	});
	var $reviews = $('#reviews');
	$reviews.imagesLoaded(function(){
	  $reviews.masonry({
	    itemSelector : '.feed_obj',
			isResizable: true,
	  });
	});
}

//Rating for vote
function stars() {
	$(".stars").rating({showCancel: null});
}