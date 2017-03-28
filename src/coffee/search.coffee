###### Get User's Current Location #####

fillPosition = (position, target, submit) ->
  if "coords" of position
    if "latitude" of position.coords and "longitude" of position.coords
      query = "#{position.coords.latitude},#{position.coords.longitude}"
      $ target
      .val query

      $ submit
      .submit()

window.getCurrentLocation = (target, submit) ->
  if "geolocation" of window.navigator
    navigator.geolocation.getCurrentPosition (position) ->
      fillPosition(position, target, submit)
    , (error) ->
      if error.code = 1 # (1) PERMISSION_DENIED
        alert "Please enable geolocation to see nearby results."
      else # (2) POSITION_UNAVAILABLE and (3) TIMEOUT
        alert 'Unable to retrieve your location.'
  else
    alert "Sorry, but we cannot determine your location."

searcherMapSetup = () ->

  searchMaps = []
  desktopMap = null
  mobileMap = null

  autoLoadDesktopMap = document.documentElement.clientWidth > 768

  # load mobile map on click
  $ '#js-map-details'
    .click (e) ->
      unless window.Yext.Maps.mobileLoaded?
        window.Yext.Maps.prepareGoogleMap mobileMap
        window.Yext.Maps.mobileLoaded = true

  handleResize = () ->
    unless window.Yext.Maps.desktopLoaded?
      if window.documentElement.clientWidth > 768
        window.Yext.Maps.prepareGoogleMap desktopMap
        window.Yext.Maps.desktopLoaded = true

  $(window).resize(_.debounce(handleResize, 300))

  window.Yext.Callbacks.googleMapsSetupCallback = () ->
    for map in window.mapConfig.maps
      searchMaps.push map

      if map.mapID == "dir-map-desktop-map"
        desktopMap = map
        if autoLoadDesktopMap
          window.Yext.Maps.prepareGoogleMap map
          window.Yext.Maps.desktopLoaded = true

      else if map.mapID == "dir-map-mobile-map"
        mobileMap = map

    window.mapConfig.maps = []

searcherMapSetup()