$(document).ready(function() {
	
	//Список городов
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
	
	//Центральное меню
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
		});
	});
	
	$('.sub li a').mouseover(function(){
		$('.sub li a').removeClass('active')
		$(this).addClass('active')
	});
	
	$('.sub li a').mouseout(function(){
		$(this).removeClass('active')
		$('.sub li a.selected').addClass('active')
	});
	
	//Rating for vote
	stars()
	function stars() {
		$(".stars").rating({showCancel: null});
	}
	
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
	
	//Filters Slider
	slider()
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
	
	// Floats
	floats()
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
	
})
//Google maps
// Gmaps.map.markers = [{"lng": "37.5981", "lat": "55.7534", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|1", "description": "Ресторан тайской кухни ТАЙ ТАЙ", "title": "Ресторан тайской кухни ТАЙ ТАЙ"},{"lng": "37.6416", "lat": "55.7586", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|1", "description": "Ресторан тайской кухни ТАЙ ТАЙ", "title": "Ресторан тайской кухни ТАЙ ТАЙ"},{"lng": "37.562", "lat": "55.732", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|2", "description": "Nooning", "title": "Nooning"},{"lng": "37.5932", "lat": "55.731", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|3", "description": "Белый Журавль", "title": "Белый Журавль"},{"lng": "37.6605", "lat": "55.7629", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|4", "description": "15-й шар", "title": "15-й шар"},{"lng": "37.7949", "lat": "55.758", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|5", "description": "Новогиреевское", "title": "Новогиреевское"},{"lng": "37.5054", "lat": "55.8089", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|6", "description": "Очарование Востока", "title": "Очарование Востока"},{"lng": "37.6404", "lat": "55.7575", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|7", "description": "Art-Garbage Запасник", "title": "Art-Garbage Запасник"},{"lng": "37.5249", "lat": "55.6677", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|8", "description": "Пещера (на Новаторов)", "title": "Пещера (на Новаторов)"},{"lng": "37.6062", "lat": "55.7668", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|9", "description": "Пивной бар на Пушкинской", "title": "Пивной бар на Пушкинской"},{"lng": "37.6082", "lat": "55.7672", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|10", "description": "Bocconcino", "title": "Bocconcino"},{"lng": "37.488", "lat": "55.732", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|10", "description": "Bocconcino", "title": "Bocconcino"},{"lng": "37.5982", "lat": "55.7829", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|10", "description": "Bocconcino", "title": "Bocconcino"},{"lng": "37.6356", "lat": "55.7392", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|11", "description": "Giovedi Cafe", "title": "Giovedi Cafe"},{"lng": "37.6356", "lat": "55.7392", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|12", "description": "Giovedi Cafe", "title": "Giovedi Cafe"},{"lng": "37.4907", "lat": "55.8104", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|13", "description": "Райхан", "title": "Райхан"},{"lng": "37.6605", "lat": "55.7629", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|14", "description": "15-й шар", "title": "15-й шар"},{"lng": "37.7744", "lat": "55.7595", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|15", "description": "Amigos", "title": "Amigos"},{"lng": "37.5509", "lat": "55.6642", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|16", "description": "Очаг Султана", "title": "Очаг Султана"},{"lng": "37.6115", "lat": "55.7318", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|17", "description": "Панчо Вилья", "title": "Панчо Вилья"},{"lng": "37.5826", "lat": "55.8025", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|18", "description": "BeerМаркет", "title": "BeerМаркет"},{"lng": "37.5834", "lat": "55.7917", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|19", "description": "Пиво-Хаус", "title": "Пиво-Хаус"},{"lng": "37.6357", "lat": "55.7773", "picture": "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|ff776b|12|_|20", "description": "Cocon Home", "title": "Cocon Home"}];
function load_map() {
  var myOptions = {
    zoom: 6,
    center: new google.maps.LatLng(-33.9, 151.2),
		mapTypeControl: false,
		streetViewControl: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  if ($("#map_canvas").length) {
		var map = new google.maps.Map($("#map_canvas")[0], myOptions);
	}
	if ($("#map_canvas_popup").length) {
		var map = new google.maps.Map($("#map_canvas_popup")[0], myOptions);
	}
  setMarkers(map, markers);
}

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
      coord: [1, 1, 1, 20, 18, 20, 18 , 1],
      type: 'poly'
  };
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
  }
}