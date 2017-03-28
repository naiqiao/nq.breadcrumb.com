window.Yext = ((Yext) ->
  Yext.Maps = ((Maps) ->

    Maps.autoLoadMaps = true

    Maps.prepareGoogleMap = (mapObject) ->

      locs = mapObject.locs
      nearbyLocs = mapObject.nearbyLocs
      baseUrl = mapObject.baseUrl
      source = mapObject.source
      zoom = mapObject.zoom
      disableMapControl = mapObject.disableMapControl
      mapID = mapObject.mapID

      opts =
        mapTypeId: google.maps.MapTypeId.ROADMAP
        zoom: zoom
        disableDefaultUI: disableMapControl
        disableDoubleClickZoom: disableMapControl
        draggable: not disableMapControl
        panControl: not disableMapControl
        scrollwheel: not disableMapControl

      bounds = new google.maps.LatLngBounds()
      infowindow = new google.maps.InfoWindow()

      locations = locs.concat nearbyLocs

      if locs.length > 0
        opts['center'] = new google.maps.LatLng(locs[0].latitude, locs[0].longitude)

      opts = window.Yext.Callbacks.customizeMapOptions(opts) if window.Yext?.Callbacks?.customizeMapOptions?

      window.map = new google.maps.Map(document.getElementById(mapID), opts)

      map = window.map
      map = window.Yext.Callbacks.preConfigureMap(map) if window.Yext.Callbacks.preConfigureMap?

      idx = 0
      for location in locations
        (
          (i, loc, m) ->
            pin = new google.maps.Marker(
              position: new google.maps.LatLng(loc.latitude, loc.longitude)
              icon: loc.smallpin
              map: m
            )
            bounds.extend pin.position

            google.maps.event.addListener pin, "click", ->
              clickHandler(loc.url, Yext.BaseUrl)
              return

            pin = window.Yext.Callbacks.configureGoogleMapsPin(m, loc, pin, i) if window.Yext?.Callbacks?.configureGoogleMapsPin?
            return
        )(idx, location, map)
        idx++

      map.fitBounds bounds  if locations.length != 1
      google.maps.event.addListener map, "click", ->
        infowindow.close()
        return

      if locations.length == 0
        window.google.maps.event.addListenerOnce map, 'idle', ()->
          map.setCenter({lat: 39.833333, lng: -98.583333}) # United States Center
          map.setZoom(4)

      if mapLoadedCallback?
        window.google.maps.event.addListenerOnce map, 'idle', () ->
          mapLoadedCallback map

      google.maps.event.addDomListener window, 'resize', () ->
        center = map.getCenter()
        google.maps.event.trigger map, 'resize'
        map.setCenter center
        return

      return

    Maps.prepareBingMap = (mapObject) ->
      locs = mapObject.locs
      nearbyLocs = mapObject.nearbyLocs
      baseUrl = mapObject.baseUrl
      source = mapObject.source
      zoom = mapObject.zoom
      disableMapControl = mapObject.disableMapControl
      mapID = mapObject.mapID
      apiID = mapObject.apiID

      pinLayer = new Microsoft.Maps.EntityCollection()
      map = new Microsoft.Maps.Map(document.getElementById(mapID),
        credentials: apiID
        center: new Microsoft.Maps.Location(locs[0].latitude, locs[0].longitude)
        mapTypeId: Microsoft.Maps.MapTypeId.road
        zoom: zoom
        disableUserInput: disableMapControl
        showScalebar: not disableMapControl
        showMapTypeSelector: not disableMapControl
        showDashboard: false
        enableSearchLogo: false
      )
      options = map.getOptions()
      locations = []

      index = 0
      allLocations = locs.concat nearbyLocs
      while index < allLocations.length
        ((i, allLocs) ->
          loc = new Microsoft.Maps.Location(allLocs[i].latitude, allLocs[i].longitude)
          pin = new Microsoft.Maps.Pushpin(loc,
            icon: allLocs[i].smallpin
            height: "37px"
            width: "26px"
            anchor: new Microsoft.Maps.Point(13, 37)
          )
          pinLayer.push pin
          locations.push loc
          ch = (e) ->
            console.log "clicked"
            if e.targetType is "pushpin"
              if source is "locationlist"
                options.center = e.target.getLocation()
                map.setView options
              else if linkToGetDirections
                window.open allLocs[i].url, '_blank'
              else
                window.location.href = baseUrl + allLocs[i].url
            return
          # it does not look like this click handler has ever worked :/
          Microsoft.Maps.Events.addHandler pin, "click", ch
          return

        )(index, allLocations)
        index++
        if index > 100
          break

      map.setView bounds: Microsoft.Maps.LocationRect.fromLocations(locations)
      map.entities.push pinLayer

      if mapLoadedCallback?
        mapLoadedCallback map

      return

    Maps.prepareMapQuestMap = (mapObject) ->
      locs = mapObject.locs
      nearbyLocs = mapObject.nearbyLocs
      baseUrl = mapObject.baseUrl
      source = mapObject.source
      zoom = mapObject.zoom
      disableMapControl = mapObject.disableMapControl
      mapID = mapObject.mapID
      apiID = mapObject.apiID

      locations = locs.concat nearbyLocs

      sc = new MQA.ShapeCollection()
      for location in locations
        ((loc) ->
          poi = new MQA.Poi
            lat: loc.latitude
            lng: loc.longitude

          MQA.EventManager.addListener poi, 'click', (evt) ->
            clickHandler(loc.url, Yext.BaseUrl)
          icon = new MQA.Icon(loc.smallpin, 26, 37)
          poi.setIcon(icon)
          sc.add(poi)
        )(location)

      map = new MQA.TileMap
        elt: mapID,
        zoom: zoom,
        mtype: 'map',
        bestFitMargin: 100,
        zoomOnDoubleClick: !disableMapControl
        collection: sc
      map.setDraggable(!disableMapControl)

      return

    clickHandler = (url, baseUrl) ->
      if url.indexOf('http') == 0
        window.open url, '_blank'
      else
        window.location.href = baseUrl + url

    Maps.prepareMapboxMap = (mapObject) ->
      locs = mapObject.locs
      nearbyLocs = mapObject.nearbyLocs
      baseUrl = mapObject.baseUrl
      source = mapObject.source
      zoom = mapObject.zoom
      disableMapControl = mapObject.disableMapControl
      mapID = mapObject.mapID
      apiID = mapObject.apiID

      map = L.mapbox.map mapID, mapObject.mapboxMapIdentifier,
        zoomControl: not disableMapControl
        attributionControl: false

      if disableMapControl
        map.dragging.disable()
        map.touchZoom.disable()
        map.doubleClickZoom.disable()
        map.scrollWheelZoom.disable()
        map.tap.disable() if map.tap

      markerPositions = []

      for location in locs.concat(nearbyLocs)
        ((loc, m) ->
          latlng = L.latLng(loc.latitude, loc.longitude)

          if Yext?.pages?.maps?.mapbox?.markerConfigFor?
            markerConfig = Yext.pages.maps.mapbox.markerConfigFor(loc)
          else
            markerConfig = icon: new L.Icon.Default()

          marker = L.marker(latlng, markerConfig)

          marker.on 'click', ->
            clickHandler(loc.url, baseUrl)

          marker.addTo(m)
          markerPositions.push latlng
        )(location, map)

      if locs.length > 1
        map.fitBounds(L.latLngBounds(markerPositions))
      else
        map.setView(markerPositions[0], zoom)

      if mapLoadedCallback?
        mapLoadedCallback map

      return

    loadGoogleMaps = (apiId, versionType) ->
      script = document.createElement 'script'
      script.type = "text/javascript"
      script.src = "//maps.googleapis.com/maps/api/js?#{versionType}=#{apiId}&sensor=false&v=3.19&channel=#{window.mapConfig.channelId}&callback=initializeMaps"

      document.body.appendChild(script)

    loadBingMaps = () ->
      script = document.createElement 'script'
      script.type = "text/javascript"
      script.src = '//ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&onScriptLoad=initializeMaps'

      document.body.appendChild(script)

    loadMapQuestMaps = (apiId) ->
      endpoint = '//mapquestapi.com/sdk/js/v7.2.s/mqa.toolkit.js?key=' # Enterprise endpoint
      if apiId == 'Fmjtd%7Cluu829urnh%2Cbn%3Do5-9w1ghy'
        endpoint = '//open.mapquestapi.com/sdk/js/v7.2.s/mqa.toolkit.js?key=' # Developer "Open" endpoint
      $.getScript "#{endpoint}#{apiId}", (data, textStatus, jqxhr) ->
        if jqxhr.status == 200
          window.initializeMaps()

    addRemoteCSS = (url) ->
      link = document.createElement 'link'
      link.rel = 'stylesheet'
      link.href = url
      document.body.appendChild(link)

    loadMapboxMaps = (apiId) ->
      version = "v2.1.6"
      addRemoteCSS("https://api.tiles.mapbox.com/mapbox.js/#{version}/mapbox.css")
      $.getScript "https://api.tiles.mapbox.com/mapbox.js/#{version}/mapbox.js", (data, textStatus, jqxhr) ->
        if jqxhr.status == 200
          L.mapbox.accessToken = apiId
          window.initializeMaps()

    window.initializeMaps = () ->
      if window.Yext?.Callbacks?.googleMapsSetupCallback? then window.Yext.Callbacks.googleMapsSetupCallback()

      for map in window.mapConfig.maps
        switch map.provider
          when 'Google', 'Google-Free' then Maps.prepareGoogleMap map
          when 'Bing' then Maps.prepareBingMap map
          when 'MapQuest' then Maps.prepareMapQuestMap map
          when 'Mapbox' then Maps.prepareMapboxMap map

    Maps.loadMapProviders = () ->
      if window.mapConfig? and window.mapConfig.channelId? and window.mapConfig.maps.length?
        mapProviders = {}

        for map in window.mapConfig.maps
          unless mapProviders[map.provider]?
            mapProviders[map.provider] = map.apiID

        for provider, apiID of mapProviders
          switch provider
            when 'Google' then loadGoogleMaps apiID, 'client' # Enterprise
            when 'Google-Free' then loadGoogleMaps apiID, 'key' #Free Edition
            when 'Bing' then loadBingMaps()
            when 'MapQuest' then loadMapQuestMaps apiID
            when 'Mapbox' then loadMapboxMaps apiID

    return Maps
  )(window.Yext.Maps or {})
  return Yext
)(window.Yext or {})

$ ->
  unless window.Yext.Maps.autoLoadMaps == false
    window.Yext.Maps.loadMapProviders()
