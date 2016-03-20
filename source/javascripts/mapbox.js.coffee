window.loadMapBox = ->
  customIcon = L.icon({
    iconUrl: '/images/map_pin.png',
    iconRetinaUrl: '/images/map_pin@2x.png',
    iconSize: [20, 20],
    iconAnchor: [10, 10],
    popupAnchor: [0, -10]
  })

  mapDiv = $('#map')
  if mapDiv.length > 0
    id = mapDiv.data('mapbox-id') || 'matsimitsu.p5d83n89'
    map = L.mapbox.map('map', id, {
      featureLayer: false,
      scrollWheelZoom: false,
      zoomControl: mapDiv.data('zoom-control') != false
    })

    if mapDiv.data('zoom-control') == false
      map.dragging.disable();
      map.touchZoom.disable();
      map.doubleClickZoom.disable();
      map.scrollWheelZoom.disable();
      map.keyboard.disable();
      if (map.tap)
        map.tap.disable();

    if mapDiv.data('locations')
      #mapDiv.height($(window).height() - $('footer').outerHeight(true))

      markers = []
      for location in mapDiv.data('locations')
        marker = L.marker(location.latlng, {
          icon: customIcon,
          title: location.title,
          clickable: true
        })
        marker.bindPopup("<a href=\"#{location.url}\">#{location.title}</a>", {closeButton: false}).openPopup()
        markers.push marker
        marker.addTo(map)

      if mapDiv.data('center')
        zoom = mapDiv.data('zoom') || 8
        map.setView(mapDiv.data('center'), zoom)
      else if markers.length > 1
        group = new L.featureGroup(markers)
        map.fitBounds(group.getBounds().pad(0.1))
        map.setZoom(14) if map.getZoom() > 14
      else
        map.setView(mapDiv.data('locations')[0].latlng, 8)
    else
      map.setView(mapDiv.data('location'), 7 )
      L.marker(mapDiv.data('location'), {icon: customIcon}).addTo(map);
