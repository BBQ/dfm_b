$(document).bind('pagecreate',function(){
	
	$('.btn_agree, .btn_disagree').live('click', function(){
		$status = $(this).parent('.op_btns').prev('.op_status')
		
		if ($(this).hasClass('btn_agree')) {
			$status.css('background', "url('images/op_btns.jpg') 0 -48px")
		}
		
		if ($(this).hasClass('btn_disagree')) {
			$status.css('background', "url('images/op_btns.jpg') 0 -96px")
		}
		
		$(this).parent('.op_btns').fadeOut()
		$status.slideDown()
	})
	
	$('.op_status').live('click', function(){
		$(this).fadeOut()
		$(this).next('.op_btns').fadeIn()
	})
	
	
	$('.btn_agree_d, .btn_disagree_d').live('click', function(){
		$status = $(this).parent('.op_btns_d').prev('.op_status_d')
		
		if ($(this).hasClass('btn_agree_d')) {
			$status.css('background', "url('images/td-choise-buttons.png') 0 -40px")
		}
		
		if ($(this).hasClass('btn_disagree_d')) {
			$status.css('background', "url('images/td-choise-buttons.png') 0 -80px")
		}
		
		$(this).parent('.op_btns_d').fadeOut()
		$status.slideDown()
	})
	
	$('.op_status_d').live('click', function(){
		$(this).fadeOut()
		$(this).next('.op_btns_d').fadeIn()
	})
	
	$('.users').live('tap', function(event){
		swipe_users('left',$(this))
	})
		
	$('.users').live('swipeleft', function(event){
		swipe_users('left',$(this))
	})
	
	$('.users').live('swiperight', function(event){
		swipe_users('right',$(this))
	})
	
	$('.rrinfo').live('swipeleft', function(event){
		$element = $(this);
		$div = $(this).parent('.review').children('.more_place_info')
		swipe_info($element, $div, 'left')
	})
	
	$('.more_place_info').live('swiperight', function(event){
		$element = $(this);
		$div = $(this).parent('.review').children('.rrinfo')
		swipe_info($element, $div, 'right')
	})
	
	$('.dish .rating').live('swipeleft', function(event){
		$element = $(this);
		$div = $(this).next('.dish_info')		
		swipe_info($element, $div, 'left')
	})
	
	$('.dish_info').live('swiperight', function(event){
		
		$element = $(this);
		$div = $(this).prev('.rating')
		console.log($div)
		swipe_info($element, $div, 'right')
	})
	
})

function swipe_info(element, div, direction) {
	if (direction == 'left'){
		if (parseInt(element.css('right'),10) == 0){
			element.animate({right: element.parent().outerWidth()}, 300);
			div.animate({left:0}, 220);
		}
	}
	if (direction == 'right'){
		if (parseInt(element.css('left'),10) == 0){
			$div.animate({right:0}, 300)
			$element.animate({left:element.outerWidth()}, 300)
		}
	}
}


function swipe_users(direction, object) {
	if (direction == 'left') {
		object.children('.num').fadeOut()
		object.children('.text').fadeOut()
		object.prev('.stats').fadeOut()
		object.animate({width: '254px'}, 300, function() {
			object.children('.profiles').fadeIn();
		});

	}
	if (direction == 'right') {
		object.animate({width: '84px'}, 300,  function() {
			object.children('.profiles').fadeOut()
			object.children('.num').fadeIn()
			object.children('.text').fadeIn()
		});
		object.prev('.stats').fadeIn()
	}
}

function load_map(markers, element_id) {
  var mapOptions = {
		mapTypeControl: false,
		streetViewControl: false,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		maxZoom: 17,
		center: new google.maps.LatLng(0,0)
  }
  map = new google.maps.Map(document.getElementById(element_id),mapOptions);
	setMarkers(map, markers);
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
  var image = new google.maps.MarkerImage('http://dish.fm/images/mapPointer.png',
      // This marker is 20 pixels wide by 32 pixels tall.
      new google.maps.Size(26, 42),
      // The origin for this image is 0,0.
      new google.maps.Point(0,0),
      // The anchor for this image is the base of the flagpole at 0,32.
      new google.maps.Point(0, 42));
  // var shadow = new google.maps.MarkerImage('http://code.google.com/intl/ru-RU/apis/maps/documentation/javascript/examples/images/beachflag_shadow.png',
      // The shadow image is larger in the horizontal dimension
      // while the position and offset are the same as for the main image.
      // new google.maps.Size(37, 32),
      // new google.maps.Point(0,0),
      // new google.maps.Point(0, 32));
      // Shapes define the clickable region of the icon.
      // The type defines an HTML <area> element 'poly' which
      // traces out a polygon as a series of X,Y points. The final
      // coordinate closes the poly by connecting to the first
      // coordinate.
  var shape = {
      coord: [1, 1, 1, 26, 21, 26, 21, 1],
      type: 'poly'
  };
	var bounds = new google.maps.LatLngBounds();
  for (var i = 0; i < locations.length; i++) {
    var beach = locations[i];
    var myLatLng = new google.maps.LatLng(beach[1], beach[2]);
    var marker = new google.maps.Marker({
        position: myLatLng,
        map: map,
        icon: image,
        shape: shape,
        title: beach[0],
        zIndex: beach[3]
    });
		bounds.extend(myLatLng);
  }
	map.fitBounds(bounds);
}

