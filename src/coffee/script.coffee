window.Yext = ((Yext) ->
  Yext.Callbacks =
    hoursWillRun: ->
      # this runs before hours data gets loaded
    hoursProcessed: (hoursInstance) ->
      # this is an example callback
    customizeMapOptions: (opts) ->
      return $.extend opts,
        scrollwheel: false
        draggable: false

    preConfigureMap: (map) ->
      return map
    configureGoogleMapsPin: (map, loc, pin, i) ->

      # do stuff here like add customized click handler or an info window

      return pin

    ytPlayersReady: () ->
      $ '#modal'
        .on 'hidden.bs.modal', () ->
          $ '#modal .youtube-embed'
            .each (idx, el) ->
              el.player.stopVideo()
  return Yext
)(window.Yext || {})

$ ->
  $ '[data-ga-event]'
    .each (idx, el) ->
      data = $(@).data 'ga-event'
      if $(el).data('ga-event-outbound')
        clickTarget = $(el)
        href = $(el).attr 'href'

        data.hitCallback = () ->
          unless $(clickTarget).attr('target') is '_blank'
            document.location = href

      $(el).click (e) ->
        ga 'send', data

  $ '.search-content-wrapper .search-button'
    .click ->
      ga 'send',
        'hitType': 'event',
        'eventCategory': 'Locator',
        'eventAction': 'CTA',
        'eventLabel': 'Locator_Go',

